(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open Core
open Ast
open Analysis

module ClassDefinitionsCache : sig
  val invalidate : unit -> unit
end

val class_summaries
  :  resolution:GlobalResolution.t ->
  Reference.t ->
  Statement.Class.t Node.t list option

val find_method_definitions
  :  resolution:GlobalResolution.t ->
  ?predicate:(Statement.Define.t -> bool) ->
  Reference.t ->
  Type.type_t Type.Callable.overload list

module Global : sig
  type t =
    | Class
    | Module
    | Attribute of Type.t
  [@@deriving show]
end

val resolve_global : resolution:GlobalResolution.t -> Reference.t -> Global.t option

(* Exposed for testing. *)
val demangle_class_attribute : string -> string

val verify_signature
  :  path:PyrePath.t option ->
  location:Location.t ->
  normalized_model_parameters:AccessPath.NormalizedParameter.t list ->
  name:Reference.t ->
  Type.Callable.t option ->
  (unit, ModelVerificationError.t) result

val verify_global
  :  path:PyrePath.t option ->
  location:Location.t ->
  resolution:GlobalResolution.t ->
  name:Reference.t ->
  (unit, ModelVerificationError.t) result
