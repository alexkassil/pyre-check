"use strict";(self.webpackChunk=self.webpackChunk||[]).push([[9817],{34228:(e,t,a)=>{a.r(t),a.d(t,{default:()=>I});var n=a(67294),r=a(1944),i=a(24575),l=a(44996),s=a(86010),o=a(39960),c=a(13919),d=a(95999);const u="cardContainer_fWXF",m="cardTitle_rnsV",v="cardDescription_PWke";function f(e){var t=e.href,a=e.children;return n.createElement(o.default,{href:t,className:(0,s.default)("card padding--lg",u)},a)}function h(e){var t=e.href,a=e.icon,r=e.title,i=e.description;return n.createElement(f,{href:t},n.createElement("h2",{className:(0,s.default)("text--truncate",m),title:r},a," ",r),i&&n.createElement("p",{className:(0,s.default)("text--truncate",v),title:i},i))}function g(e){var t=e.item,a=(0,i.Wl)(t);return a?n.createElement(h,{href:a,icon:"\ud83d\uddc3\ufe0f",title:t.label,description:(0,d.translate)({message:"{count} items",id:"theme.docs.DocCard.categoryDescription",description:"The default description for a category card in the generated index about how many items this category includes"},{count:t.items.length})}):null}function E(e){var t,a=e.item,r=(0,c.Z)(a.href)?"\ud83d\udcc4\ufe0f":"\ud83d\udd17",l=(0,i.xz)(null!=(t=a.docId)?t:void 0);return n.createElement(h,{href:a.href,icon:r,title:a.label,description:null==l?void 0:l.description})}function b(e){var t=e.item;switch(t.type){case"link":return n.createElement(E,{item:t});case"category":return n.createElement(g,{item:t});default:throw new Error("unknown item type "+JSON.stringify(t))}}function p(e){var t=e.className,a=(0,i.jA)();return n.createElement(N,{items:a.items,className:t})}function N(e){var t=e.items,a=e.className;if(!t)return n.createElement(p,e);var r=(0,i.MN)(t);return n.createElement("section",{className:(0,s.default)("row",a)},r.map((function(e,t){return n.createElement("article",{key:t,className:"col col--6 margin-bottom--lg"},n.createElement(b,{item:e}))})))}var k=a(4966),L=a(23120),T=a(44364),_=a(19089),x=a(92503);const y="generatedIndexPage_vN6x",Z="list_eTzJ",w="title_kItE";function V(e){var t=e.categoryGeneratedIndex;return n.createElement(r.d,{title:t.title,description:t.description,keywords:t.keywords,image:(0,l.default)(t.image)})}function C(e){var t=e.categoryGeneratedIndex,a=(0,i.jA)();return n.createElement("div",{className:y},n.createElement(L.Z,null),n.createElement(_.Z,null),n.createElement(T.Z,null),n.createElement("header",null,n.createElement(x.Z,{as:"h1",className:w},t.title),t.description&&n.createElement("p",null,t.description)),n.createElement("article",{className:"margin-top--lg"},n.createElement(N,{items:a.items,className:Z})),n.createElement("footer",{className:"margin-top--lg"},n.createElement(k.Z,{previous:t.navigation.previous,next:t.navigation.next})))}function I(e){return n.createElement(n.Fragment,null,n.createElement(V,e),n.createElement(C,e))}},4966:(e,t,a)=>{a.d(t,{Z:()=>c});var n=a(83117),r=a(67294),i=a(95999),l=a(86010),s=a(39960);function o(e){var t=e.permalink,a=e.title,n=e.subLabel,i=e.isNext;return r.createElement(s.default,{className:(0,l.default)("pagination-nav__link",i?"pagination-nav__link--next":"pagination-nav__link--prev"),to:t},n&&r.createElement("div",{className:"pagination-nav__sublabel"},n),r.createElement("div",{className:"pagination-nav__label"},a))}function c(e){var t=e.previous,a=e.next;return r.createElement("nav",{className:"pagination-nav docusaurus-mt-lg","aria-label":(0,i.translate)({id:"theme.docs.paginator.navAriaLabel",message:"Docs pages navigation",description:"The ARIA label for the docs pagination"})},t&&r.createElement(o,(0,n.Z)({},t,{subLabel:r.createElement(i.default,{id:"theme.docs.paginator.previous",description:"The label used to navigate to the previous doc"},"Previous")})),a&&r.createElement(o,(0,n.Z)({},a,{subLabel:r.createElement(i.default,{id:"theme.docs.paginator.next",description:"The label used to navigate to the next doc"},"Next"),isNext:!0})))}},44364:(e,t,a)=>{a.d(t,{Z:()=>o});var n=a(67294),r=a(86010),i=a(95999),l=a(35281),s=a(74477);function o(e){var t=e.className,a=(0,s.E)();return a.badge?n.createElement("span",{className:(0,r.default)(t,l.k.docs.docVersionBadge,"badge badge--secondary")},n.createElement(i.default,{id:"theme.docs.versionBadge.label",values:{versionLabel:a.label}},"Version: {versionLabel}")):null}},23120:(e,t,a)=>{a.d(t,{Z:()=>g});var n=a(67294),r=a(86010),i=a(52263),l=a(39960),s=a(95999),o=a(94104),c=a(35281),d=a(60373),u=a(74477);var m={unreleased:function(e){var t=e.siteTitle,a=e.versionMetadata;return n.createElement(s.default,{id:"theme.docs.versions.unreleasedVersionLabel",description:"The label used to tell the user that he's browsing an unreleased doc version",values:{siteTitle:t,versionLabel:n.createElement("b",null,a.label)}},"This is unreleased documentation for {siteTitle} {versionLabel} version.")},unmaintained:function(e){var t=e.siteTitle,a=e.versionMetadata;return n.createElement(s.default,{id:"theme.docs.versions.unmaintainedVersionLabel",description:"The label used to tell the user that he's browsing an unmaintained doc version",values:{siteTitle:t,versionLabel:n.createElement("b",null,a.label)}},"This is documentation for {siteTitle} {versionLabel}, which is no longer actively maintained.")}};function v(e){var t=m[e.versionMetadata.banner];return n.createElement(t,e)}function f(e){var t=e.versionLabel,a=e.to,r=e.onClick;return n.createElement(s.default,{id:"theme.docs.versions.latestVersionSuggestionLabel",description:"The label used to tell the user to check the latest version",values:{versionLabel:t,latestVersionLink:n.createElement("b",null,n.createElement(l.default,{to:a,onClick:r},n.createElement(s.default,{id:"theme.docs.versions.latestVersionLinkLabel",description:"The label used for the latest version suggestion link label"},"latest version")))}},"For up-to-date documentation, see the {latestVersionLink} ({versionLabel}).")}function h(e){var t,a=e.className,l=e.versionMetadata,s=(0,i.default)().siteConfig.title,u=(0,o.gA)({failfast:!0}).pluginId,m=(0,d.J)(u).savePreferredVersionName,h=(0,o.Jo)(u),g=h.latestDocSuggestion,E=h.latestVersionSuggestion,b=null!=g?g:(t=E).docs.find((function(e){return e.id===t.mainDocId}));return n.createElement("div",{className:(0,r.default)(a,c.k.docs.docVersionBanner,"alert alert--warning margin-bottom--md"),role:"alert"},n.createElement("div",null,n.createElement(v,{siteTitle:s,versionMetadata:l})),n.createElement("div",{className:"margin-top--md"},n.createElement(f,{versionLabel:E.label,to:b.path,onClick:function(){return m(E.name)}})))}function g(e){var t=e.className,a=(0,u.E)();return a.banner?n.createElement(h,{className:t,versionMetadata:a}):null}},92503:(e,t,a)=>{a.d(t,{Z:()=>m});var n=a(83117),r=a(80102),i=a(67294),l=a(86010),s=a(95999),o=a(86668);const c="anchorWithStickyNavbar_LWe7",d="anchorWithHideOnScrollNavbar_WYt5";var u=["as","id"];function m(e){var t=e.as,a=e.id,m=(0,r.Z)(e,u),v=(0,o.L)().navbar.hideOnScroll;return"h1"!==t&&a?i.createElement(t,(0,n.Z)({},m,{className:(0,l.default)("anchor",v?d:c),id:a}),m.children,i.createElement("a",{className:"hash-link",href:"#"+a,title:(0,s.translate)({id:"theme.common.headingLinkTitle",message:"Direct link to heading",description:"Title for link to heading"})},"\u200b")):i.createElement(t,(0,n.Z)({},m,{id:void 0}))}},19089:(e,t)=>{t.Z=function(){return null}}}]);