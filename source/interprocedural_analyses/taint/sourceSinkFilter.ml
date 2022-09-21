(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open Core

module MatchingSanitizeTransforms = struct
  type t = {
    transforms: SanitizeTransformSet.t;
    (* False if the set of matching sources or sinks cannot be sanitized,
     * for instance if it is a transform, or a (triggered) partial sink. *)
    sanitizable: bool;
  }

  let empty = { transforms = SanitizeTransformSet.empty; sanitizable = true }

  let add_source { transforms; sanitizable } = function
    | Sources.NamedSource name
    | Sources.ParametricSource { source_name = name; _ } ->
        {
          transforms =
            SanitizeTransformSet.add_source (SanitizeTransform.Source.Named name) transforms;
          sanitizable;
        }
    | Sources.Transform _ -> { transforms; sanitizable = false }
    | Sources.Attach -> failwith "unexpected source in `matching_sources`"


  let add_sink { transforms; sanitizable } = function
    | Sinks.NamedSink name
    | Sinks.ParametricSink { sink_name = name; _ } ->
        {
          transforms = SanitizeTransformSet.add_sink (SanitizeTransform.Sink.Named name) transforms;
          sanitizable;
        }
    | Sinks.Transform _
    | Sinks.PartialSink _
    | Sinks.TriggeredPartialSink _ ->
        { transforms; sanitizable = false }
    | Sinks.LocalReturn
    | Sinks.ParameterUpdate _
    | Sinks.Attach
    | Sinks.AddFeatureToArgument ->
        failwith "unexpected sink in `matching_sinks`"


  let from_sources sources = Sources.Set.fold (Core.Fn.flip add_source) sources empty

  let from_sinks sinks = Sinks.Set.fold (Core.Fn.flip add_sink) sinks empty
end

type t = {
  matching_sources: Sources.Set.t Sinks.Map.t;
  matching_sinks: Sinks.Set.t Sources.Map.t;
  possible_tito_transforms: TaintTransforms.Set.t;
  (* These are the same as `matching_sources`/`matching_sinks`, but storing
   * sources and sinks as `SanitizeTransform.t`. *)
  matching_source_sanitize_transforms: MatchingSanitizeTransforms.t Sinks.Map.t;
  matching_sink_sanitize_transforms: MatchingSanitizeTransforms.t Sources.Map.t;
}

module IntSet = Stdlib.Set.Make (Int)

(* Given a rule to find flows of the form:
 *   source -> T1 -> T2 -> T3 -> ... -> Tn -> sink
 * Following are different ways we can find matching flows:
 *   source -> T1:T2:T3:...:Tn:sink
 *   T1:source -> T2:T3:...:Tn:sink
 *   T2:T1:source -> T3:...:Tn:sink
 *   ...
 *   Tn:...:T3:T2:T1:source -> sink
 *)
let transform_splits transforms =
  let rec split ~result ~prefix ~suffix =
    let result = (prefix, suffix) :: result in
    match suffix with
    | [] -> result
    | next :: suffix -> split ~result ~prefix:(next :: prefix) ~suffix
  in
  split ~result:[] ~prefix:[] ~suffix:transforms


let filter_rules ~filtered_rule_codes ~filtered_sources ~filtered_sinks ~filtered_transforms rules =
  let rules =
    match filtered_rule_codes with
    | Some rule_codes -> List.filter rules ~f:(fun { Rule.code; _ } -> IntSet.mem code rule_codes)
    | None -> rules
  in
  let rules =
    match filtered_sources with
    | Some filtered_sources ->
        let should_keep_source = function
          | Sources.NamedSource name
          | Sources.ParametricSource { source_name = name; _ } ->
              Sources.Set.mem (Sources.NamedSource name) filtered_sources
          | _ -> true
        in
        List.filter_map rules ~f:(fun rule ->
            let rule_sources = List.filter ~f:should_keep_source rule.sources in
            if not (List.is_empty rule_sources) then
              Some { rule with sources = rule_sources }
            else
              None)
    | None -> rules
  in
  let rules =
    match filtered_sinks with
    | Some filtered_sinks ->
        let should_keep_sink = function
          | Sinks.NamedSink name
          | Sinks.ParametricSink { sink_name = name; _ } ->
              Sinks.Set.mem (Sinks.NamedSink name) filtered_sinks
          | _ -> true
        in
        List.filter_map rules ~f:(fun rule ->
            let rule_sinks = List.filter ~f:should_keep_sink rule.sinks in
            if not (List.is_empty rule_sinks) then
              Some { rule with sinks = rule_sinks }
            else
              None)
    | None -> rules
  in
  let rules =
    match filtered_transforms with
    | Some filtered_transforms ->
        let should_keep_transform = List.mem filtered_transforms ~equal:TaintTransform.equal in
        List.filter rules ~f:(fun rule -> List.for_all rule.transforms ~f:should_keep_transform)
    | None -> rules
  in
  rules


let matching_kinds_from_rules ~rules =
  let add_sources_sinks (matching_sources, matching_sinks) (sources, sinks) =
    let sinks_set = Sinks.Set.of_list sinks in
    let sources_set = Sources.Set.of_list sources in
    let update_matching_sources matching_sources sink =
      Sinks.Map.update
        sink
        (function
          | None -> Some sources_set
          | Some sources -> Some (Sources.Set.union sources sources_set))
        matching_sources
    in
    let update_matching_sinks matching_sinks source =
      Sources.Map.update
        source
        (function
          | None -> Some sinks_set
          | Some sinks -> Some (Sinks.Set.union sinks sinks_set))
        matching_sinks
    in
    let matching_sources = List.fold ~f:update_matching_sources ~init:matching_sources sinks in
    let matching_sinks = List.fold ~f:update_matching_sinks ~init:matching_sinks sources in
    matching_sources, matching_sinks
  in
  let add_rule sofar { Rule.sources; sinks; transforms; _ } =
    let update sofar (source_transforms, sink_transforms) =
      let sources =
        if List.is_empty source_transforms then
          sources
        else
          List.map sources ~f:(fun base ->
              Sources.Transform
                {
                  base;
                  global = TaintTransforms.of_named_transforms source_transforms;
                  local = TaintTransforms.empty;
                })
      in
      let sinks =
        if List.is_empty sink_transforms then
          sinks
        else
          List.map sinks ~f:(fun base ->
              Sinks.Transform
                {
                  base;
                  global = TaintTransforms.of_named_transforms sink_transforms;
                  local = TaintTransforms.empty;
                })
      in
      add_sources_sinks sofar (sources, sinks)
    in
    transform_splits transforms |> List.fold ~init:sofar ~f:update
  in
  List.fold ~f:add_rule ~init:(Sinks.Map.empty, Sources.Map.empty) rules


(* For a TITO to extend to an actual issue, the transforms in it must be a substring (contiguous
   subsequence) of transforms appearing in a rule. In addition to optimization, this is used for
   ensuring termination. We do not consider arbitrarily long transform sequences in the analysis. *)
let possible_tito_transforms_from_rules ~rules =
  let rec suffixes l = l :: Option.value_map (List.tl l) ~default:[] ~f:suffixes in
  let prefixes l = List.rev l |> suffixes |> List.map ~f:List.rev in
  let substrings l = List.concat_map (prefixes l) ~f:suffixes in
  List.concat_map rules ~f:(fun { Rule.transforms; _ } -> substrings transforms)
  |> List.map ~f:TaintTransforms.of_named_transforms
  |> TaintTransforms.Set.of_list


let create ~rules ~filtered_rule_codes ~filtered_sources ~filtered_sinks ~filtered_transforms =
  let rules =
    filter_rules ~filtered_rule_codes ~filtered_sources ~filtered_sinks ~filtered_transforms rules
  in
  let matching_sources, matching_sinks = matching_kinds_from_rules ~rules in
  let possible_tito_transforms = possible_tito_transforms_from_rules ~rules in
  let matching_source_sanitize_transforms =
    Sinks.Map.map MatchingSanitizeTransforms.from_sources matching_sources
  in
  let matching_sink_sanitize_transforms =
    Sources.Map.map MatchingSanitizeTransforms.from_sinks matching_sinks
  in
  {
    matching_sources;
    matching_sinks;
    possible_tito_transforms;
    matching_source_sanitize_transforms;
    matching_sink_sanitize_transforms;
  }


let should_keep_source { matching_sink_sanitize_transforms; _ } = function
  | Sources.Transform { local; global; base = NamedSource name }
  | Sources.Transform { local; global; base = ParametricSource { source_name = name; _ } } -> (
      let transforms = TaintTransforms.merge ~local ~global in
      let source =
        match TaintTransforms.get_named_transforms transforms with
        | [] -> Sources.NamedSource name
        | named_transforms ->
            Sources.Transform
              {
                local = TaintTransforms.empty;
                global = TaintTransforms.of_named_transforms named_transforms;
                base = Sources.NamedSource name;
              }
      in
      match Sources.Map.find_opt source matching_sink_sanitize_transforms with
      | None -> false
      | Some { sanitizable = false; _ } -> true
      | Some { transforms = matching_sinks; sanitizable = true } ->
          not
            (SanitizeTransformSet.is_empty
               (SanitizeTransformSet.diff
                  matching_sinks
                  (TaintTransforms.get_sanitize_transforms transforms))))
  | Sources.NamedSource name
  | Sources.ParametricSource { source_name = name; _ } ->
      Sources.Map.mem (Sources.NamedSource name) matching_sink_sanitize_transforms
  | _ -> true


let should_keep_sink { matching_source_sanitize_transforms; possible_tito_transforms; _ } = function
  | Sinks.Transform { local; global; base = NamedSink name }
  | Sinks.Transform { local; global; base = ParametricSink { sink_name = name; _ } } -> (
      let transforms = TaintTransforms.merge ~local ~global in
      let sink =
        match TaintTransforms.get_named_transforms transforms with
        | [] -> Sinks.NamedSink name
        | named_transforms ->
            Sinks.Transform
              {
                local = TaintTransforms.empty;
                global = TaintTransforms.of_named_transforms named_transforms;
                base = Sinks.NamedSink name;
              }
      in
      match Sinks.Map.find_opt sink matching_source_sanitize_transforms with
      | None -> false
      | Some { sanitizable = false; _ } -> true
      | Some { transforms = matching_sources; sanitizable = true } ->
          not
            (SanitizeTransformSet.is_empty
               (SanitizeTransformSet.diff
                  matching_sources
                  (TaintTransforms.get_sanitize_transforms transforms))))
  | Sinks.Transform { local; global; base = LocalReturn }
  | Sinks.Transform { local; global; base = ParameterUpdate _ } ->
      let transforms =
        TaintTransforms.merge ~local ~global |> TaintTransforms.discard_sanitize_transforms
      in
      TaintTransforms.Set.mem transforms possible_tito_transforms
  | Sinks.NamedSink name
  | Sinks.ParametricSink { sink_name = name; _ } ->
      Sinks.Map.mem (Sinks.NamedSink name) matching_source_sanitize_transforms
  | _ -> true


let matching_sources { matching_sources; _ } = matching_sources

let matching_sinks { matching_sinks; _ } = matching_sinks

let possible_tito_transforms { possible_tito_transforms; _ } = possible_tito_transforms