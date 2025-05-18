;;; json-cmp.el --- JSON 对比工具 -*- lexical-binding: t; -*-

(require 'json)
(require 'xwidget nil t)

(defvar json-cmp--session-buffer nil)
(defvar json-cmp--signal-timer nil)

;; -------------------- 1. 内置 JS 逻辑库 --------------------

(defconst json-cmp--source-map-js
  "var jsonSourceMap = (function(){
    var exports = {};
    var escapedChars={b:\"\\b\",f:\"\\f\",n:\"\\n\",r:\"\\r\",t:\"\\t\",'\"':'\"',\"/\":\"/\",\"\\\\\":\"\\\\\"},A_CODE=\"a\".charCodeAt();
    exports.parse=function(e,n,r){var t={},a=0,o=0,i=0,c=r&&r.bigint&&\"undefined\"!=typeof BigInt;return{data:f(\"\",!0),pointers:t};function f(n,r){var t;u(),d(n,\"value\");var a=v();switch(a){case\"t\":l(\"rue\"),t=!0;break;case\"f\":l(\"alse\"),t=!1;break;case\"n\":l(\"ull\"),t=null;break;case'\"':t=s();break;case\"[\":t=function(e){u();var n=[],r=0;if(\"]\"==v())return n;p();for(;;){var t=e+\"/\"+r;n.push(f(t)),u();var a=v();if(\"]\"==a)break;\",\"!=a&&k(),u(),r++}return n}(n);break;case\"{\":t=function(e){u();var n={};if(\"}\"==v())return n;p();for(;;){var r=h();'\"'!=v()&&k();var t=s(),a=e+\"/\"+escapeJsonPointer(t);g(a,\"key\",r),d(a,\"keyEnd\"),u(),\":\"!=v()&&k(),u(),n[t]=f(a),u();var o=v();if(\"}\"==o)break;\",\"!=o&&k(),u()}return n}(n);break;default:p(),\"-0123456789\".indexOf(a)>=0?t=function(){var n=\"\",r=!0;\"-\"==e[i]&&(n+=v());n+=\"0\"==e[i]?v():b(),\".\"==e[i]&&(n+=v()+b(),r=!1);\"e\"!=e[i]&&\"E\"!=e[i]||(n+=v(),\"+\"!=e[i]&&\"-\"!=e[i]||(n+=v()),n+=b(),r=!1);var t=+n;return c&&r&&(t>Number.MAX_SAFE_INTEGER||t<Number.MIN_SAFE_INTEGER)?BigInt(n):t}():S()}return d(n,\"valueEnd\"),u(),r&&i<e.length&&S(),t}function u(){e:for(;i<e.length;){switch(e[i]){case\" \":o++;break;case\"\\t\":o+=4;break;case\"\\r\":o=0;break;case\"\\n\":o=0,a++;break;default:break e}i++}}function s(){for(var e,n=\"\";'\"'!=(e=v());)\"\\\\\"==e?(e=v())in escapedChars?n+=escapedChars[e]:\"u\"==e?n+=E():k():n+=e;return n}function l(e){for(var n=0;n<e.length;n++)v()!==e[n]&&k()}function v(){if(i>=e.length)throw new SyntaxError(\"End\");var n=e[i];return i++,o++,n}function p(){i--,o--}function E(){for(var e=4,n=0;e--;){n<<=4;var r=v().toLowerCase();r>=\"a\"&&r<=\"f\"?n+=r.charCodeAt()-A_CODE+10:r>=\"0\"&&r<=\"9\"?n+=+r:k()}return String.fromCharCode(n)}function b(){for(var n=\"\";e[i]>=\"0\"&&e[i]<=\"9\";)n+=v();if(n.length)return n;S()}function d(e,n){g(e,n,h())}function g(e,n,r){t[e]=t[e]||{},t[e][n]=r}function h(){return{line:a,column:o,pos:i}}function S(){throw new SyntaxError(\"Error\")}function k(){p(),S()}function escapeJsonPointer(e){return e.replace(/~/g,\"~0\").replace(/\\//g,\"~1\")}}; return exports;
  })();")

(defconst json-cmp--json-patch-js
  "var jsonpatch = (function(){
    var exports = {};
    var fn = (function(e){var t={};function r(n){if(t[n])return t[n].exports;var o=t[n]={i:n,l:!1,exports:{}};return e[n].call(o.exports,o,o.exports,r),o.l=!0,o.exports}return r(r.s=2)})([function(e,t){Object.defineProperty(t,\"__esModule\",{value:!0});var o=Object.prototype.hasOwnProperty;function a(e,t){return o.call(e,t)}function i(e){if(Array.isArray(e)){for(var t=new Array(e.length),r=0;r<t.length;r++)t[r]=\"\"+r;return t}return Object.keys(e)}function p(e){return-1===e.indexOf(\"/\")&&-1===e.indexOf(\"~\")?e:e.replace(/~/g,\"~0\").replace(/\\//g,\"~1\")}t.hasOwnProperty=a,t._objectKeys=i,t._deepClone=function(e){return JSON.parse(JSON.stringify(e))},t.escapePathComponent=p,t.unescapePathComponent=function(e){return e.replace(/~1/g,\"/\").replace(/~0/g,\"~\")}} ,function(e,t,r){Object.defineProperty(t,\"__esModule\",{value:!0});var n=r(0);var o={add:function(e,t,r){return e[t]=this.value,{newDocument:r}},remove:function(e,t,r){var n=e[t];return delete e[t],{newDocument:r,removed:n}},replace:function(e,t,r){var n=e[t];return e[t]=this.value,{newDocument:r,removed:n}}};function p(e,r){if(\"\"===r.path){if(\"add\"===r.op)return{newDocument:r.value};if(\"replace\"===r.op)return{newDocument:r.value,removed:e};return{newDocument:e}}var d=r.path.split(\"/\"),v=e,y=1;for(;;){var O=d[y];if(O&&-1!=O.indexOf(\"~\")&&(O=n.unescapePathComponent(O)),y++,Array.isArray(v)){if(\"-\"===O)O=v.length;else O=~~O;if(y>=d.length)return o[r.op].call(r,v,O,e)}else if(y>=d.length)return o[r.op].call(r,v,O,e);v=v[O]}}t.compare=function(e,t){var r=[];function s(e,t,r,o){if(t!==e){\"function\"==typeof t.toJSON&&(t=t.toJSON());var i=n._objectKeys(t),p=n._objectKeys(e);for(var u=p.length-1;u>=0;u--){var f=e[l=p[u]];if(!n.hasOwnProperty(t,l))r.push({op:\"remove\",path:o+\"/\"+n.escapePathComponent(l)});else{var h=t[l];if(typeof f==='object'&&f!==null&&typeof h==='object'&&h!==null&&Array.isArray(f)===Array.isArray(h))s(f,h,r,o+\"/\"+n.escapePathComponent(l));else if(f!==h)r.push({op:\"replace\",path:o+\"/\"+n.escapePathComponent(l),value:h})}}for(u=0;u<i.length;u++){var l=i[u];if(!n.hasOwnProperty(e,l))r.push({op:\"add\",path:o+\"/\"+n.escapePathComponent(l),value:t[l]})}}}return s(e,t,r,\"\"),r}} ,function(e,t,r){Object.assign(t,r(1))}]);
    return fn;
  })();")

(defconst json-cmp--monaco-loader-js
  "\"use strict\";const _amdLoaderGlobal=this,_commonjsGlobal=\"object\"==typeof global?global:{};var define,AMDLoader;!function(e){e.global=_amdLoaderGlobal;class t{get isWindows(){return this._detect(),this._isWindows}get isNode(){return this._detect(),this._isNode}get isElectronRenderer(){return this._detect(),this._isElectronRenderer}get isWebWorker(){return this._detect(),this._isWebWorker}get isElectronNodeIntegrationWebWorker(){return this._detect(),this._isElectronNodeIntegrationWebWorker}constructor(){this._detected=!1,this._isWindows=!1,this._isNode=!1,this._isElectronRenderer=!1,this._isWebWorker=!1,this._isElectronNodeIntegrationWebWorker=!1}_detect(){this._detected||(this._detected=!0,this._isWindows=t._isWindows(),this._isNode=typeof module<\"u\"&&!!module.exports,this._isElectronRenderer=typeof process<\"u\"&&typeof process.versions<\"u\"&&typeof process.versions.electron<\"u\"&&\"renderer\"===process.type,this._isWebWorker=\"function\"==typeof e.global.importScripts,this._isElectronNodeIntegrationWebWorker=this._isWebWorker&&typeof process<\"u\"&&typeof process.versions<\"u\"&&typeof process.versions.electron<\"u\"&&\"worker\"===process.type)}static _isWindows(){return!!(typeof navigator<\"u\"&&navigator.userAgent&&0<=navigator.userAgent.indexOf(\"Windows\"))||typeof process<\"u\"&&\"win32\"===process.platform}}e.Environment=t}(AMDLoader=AMDLoader||{}),function(r){class i{constructor(e,t,r){this.type=e,this.detail=t,this.timestamp=r}}r.LoaderEvent=i;r.LoaderEventRecorder=class{constructor(e){this._events=[new i(1,\"\",e)]}record(e,t){this._events.push(new i(e,t,r.Utilities.getHighPerformanceTimestamp()))}getEvents(){return this._events}};class e{record(e,t){}getEvents(){return[]}}e.INSTANCE=new e,r.NullLoaderEventRecorder=e}(AMDLoader=AMDLoader||{}),function(e){class i{static fileUriToFilePath(e,t){if(t=decodeURI(t).replace(/%23/g,\"#\"),e){if(/^file:\\/\\/\\//.test(t))return t.substr(8);if(/^file:\\/\\//.test(t))return t.substr(5)}else if(/^file:\\/\\//.test(t))return t.substr(7);return t}static startsWith(e,t){return e.length>=t.length&&e.substr(0,t.length)===t}static endsWith(e,t){return e.length>=t.length&&e.substr(e.length-t.length)===t}static containsQueryString(e){return/^[^\\#]*\\?/gi.test(e)}static isAbsolutePath(e){return/^((http:\\/\\/)|(https:\\/\\/)|(file:\\/\\/)|(\\/))/.test(e)}static forEachProperty(t,r){if(t){let e;for(e in t)t.hasOwnProperty(e)&&r(e,t[e])}}static isEmpty(e){let t=!0;return i.forEachProperty(e,()=>{t=!1}),t}static recursiveClone(e){if(!e||\"object\"!=typeof e||e instanceof RegExp||!Array.isArray(e)&&Object.getPrototypeOf(e)!==Object.prototype)return e;let r=Array.isArray(e)?[]:{};return i.forEachProperty(e,(e,t)=>{r[e]=t&&\"object\"==typeof t?i.recursiveClone(t):t}),r}static generateAnonymousModule(){return\"===anonymous\"+i.NEXT_ANONYMOUS_ID+++\"===\"}static isAnonymousModule(e){return i.startsWith(e,\"===anonymous\")}static getHighPerformanceTimestamp(){return this.PERFORMANCE_NOW_PROBED||(this.PERFORMANCE_NOW_PROBED=!0,this.HAS_PERFORMANCE_NOW=e.global.performance&&\"function\"==typeof e.global.performance.now),(this.HAS_PERFORMANCE_NOW?e.global.performance:Date).now()}}i.NEXT_ANONYMOUS_ID=1,i.PERFORMANCE_NOW_PROBED=!1,i.HAS_PERFORMANCE_NOW=!1,e.Utilities=i}(AMDLoader=AMDLoader||{}),function(n){function r(e){if(e instanceof Error)return e;const t=new Error(e.message||String(e)||\"Unknown Error\");return e.stack&&(t.stack=e.stack),t}n.ensureError=r;class i{static validateConfigurationOptions(e){if(\"string\"!=typeof(e=e||{}).baseUrl&&(e.baseUrl=\"\"),\"boolean\"!=typeof e.isBuild&&(e.isBuild=!1),\"object\"!=typeof e.paths&&(e.paths={}),\"object\"!=typeof e.config&&(e.config={}),\"u\"<typeof e.catchError&&(e.catchError=!1),\"u\"<typeof e.recordStats&&(e.recordStats=!1),\"string\"!=typeof e.urlArgs&&(e.urlArgs=\"\"),\"function\"!=typeof e.onError&&(e.onError=function(e){if(\"loading\"===e.phase)return console.error('Loading \"'+e.moduleId+'\" failed'),console.error(e),console.error(\"Here are the modules that depend on it:\"),void console.error(e.neededBy);\"factory\"===e.phase&&(console.error('The factory function of \"'+e.moduleId+'\" has thrown an exception'),console.error(e),console.error(\"Here are the modules that depend on it:\"),console.error(e.neededBy))}),Array.isArray(e.ignoreDuplicateModules)||(e.ignoreDuplicateModules=[]),0<e.baseUrl.length&&(n.Utilities.endsWith(e.baseUrl,\"/\")||(e.baseUrl+=\"/\")),\"string\"!=typeof e.cspNonce&&(e.cspNonce=\"\"),\"u\"<typeof e.preferScriptTags&&(e.preferScriptTags=!1),e.nodeCachedData&&\"object\"==typeof e.nodeCachedData&&(\"string\"!=typeof e.nodeCachedData.seed&&(e.nodeCachedData.seed=\"seed\"),(\"number\"!=typeof e.nodeCachedData.writeDelay||e.nodeCachedData.writeDelay<0)&&(e.nodeCachedData.writeDelay=7e3),!e.nodeCachedData.path||\"string\"!=typeof e.nodeCachedData.path)){const t=r(new Error(\"INVALID cached data configuration, 'path' MUST be set\"));t.phase=\"configuration\",e.onError(t),e.nodeCachedData=void 0}return e}static mergeConfigurationOptions(e=null,t=null){let r=n.Utilities.recursiveClone(t||{});return n.Utilities.forEachProperty(e,(e,t)=>{\"ignoreDuplicateModules\"===e&&typeof r.ignoreDuplicateModules<\"u\"?r.ignoreDuplicateModules=r.ignoreDuplicateModules.concat(t):\"paths\"===e&&typeof r.paths<\"u\"?n.Utilities.forEachProperty(t,(e,t)=>r.paths[e]=t):\"config\"===e&&typeof r.config<\"u\"?n.Utilities.forEachProperty(t,(e,t)=>r.config[e]=t):r[e]=n.Utilities.recursiveClone(t)}),i.validateConfigurationOptions(r)}}n.ConfigurationOptionsUtil=i;n.Configuration=class t{constructor(e,t){if(this._env=e,this.options=i.mergeConfigurationOptions(t),this._createIgnoreDuplicateModulesMap(),this._createSortedPathsRules(),\"\"===this.options.baseUrl&&this.options.nodeRequire&&this.options.nodeRequire.main&&this.options.nodeRequire.main.filename&&this._env.isNode){let e=this.options.nodeRequire.main.filename,t=Math.max(e.lastIndexOf(\"/\"),e.lastIndexOf(\"\\\\\"));this.options.baseUrl=e.substring(0,t+1)}}_createIgnoreDuplicateModulesMap(){this.ignoreDuplicateModulesMap={};for(let e=0;e<this.options.ignoreDuplicateModules.length;e++)this.ignoreDuplicateModulesMap[this.options.ignoreDuplicateModules[e]]=!0}_createSortedPathsRules(){this.sortedPathsRules=[],n.Utilities.forEachProperty(this.options.paths,(e,t)=>{Array.isArray(t)?this.sortedPathsRules.push({from:e,to:t}):this.sortedPathsRules.push({from:e,to:[t]})}),this.sortedPathsRules.sort((e,t)=>t.from.length-e.from.length)}cloneAndMerge(e){return new t(this._env,i.mergeConfigurationOptions(e,this.options))}getOptionsLiteral(){return this.options}_applyPaths(i){var o;for(let e=0,t=this.sortedPathsRules.length;e<t;e++)if(o=this.sortedPathsRules[e],n.Utilities.startsWith(i,o.from)){let r=[];for(let e=0,t=o.to.length;e<t;e++)r.push(o.to[e]+i.substr(o.from.length));return r}return[i]}_addUrlArgsToUrl(e){return n.Utilities.containsQueryString(e)?e+\"&\"+this.options.urlArgs:e+\"?\"+this.options.urlArgs}_addUrlArgsIfNecessaryToUrl(e){return this.options.urlArgs?this._addUrlArgsToUrl(e):e}_addUrlArgsIfNecessaryToUrls(r){if(this.options.urlArgs)for(let e=0,t=r.length;e<t;e++)r[e]=this._addUrlArgsToUrl(r[e]);return r}moduleIdToPaths(e){if(this._env.isNode&&this.options.amdModulesPattern instanceof RegExp&&!this.options.amdModulesPattern.test(e))return this.isBuild()?[\"empty:\"]:[\"node|\"+e];let r=e,i;if(n.Utilities.endsWith(r,\".js\")||n.Utilities.isAbsolutePath(r))n.Utilities.endsWith(r,\".js\")||n.Utilities.containsQueryString(r)||(r+=\".js\"),i=[r];else for(let e=0,t=(i=this._applyPaths(r)).length;e<t;e++)this.isBuild()&&\"empty:\"===i[e]||(n.Utilities.isAbsolutePath(i[e])||(i[e]=this.options.baseUrl+i[e]),n.Utilities.endsWith(i[e],\".js\")||n.Utilities.containsQueryString(i[e])||(i[e]=i[e]+\".js\"));return this._addUrlArgsIfNecessaryToUrls(i)}requireToUrl(e){let t=e;return n.Utilities.isAbsolutePath(t)||(t=this._applyPaths(t)[0],n.Utilities.isAbsolutePath(t)||(t=this.options.baseUrl+t)),this._addUrlArgsIfNecessaryToUrl(t)}isBuild(){return this.options.isBuild}shouldInvokeFactory(e){return!!(!this.options.isBuild||n.Utilities.isAnonymousModule(e)||this.options.buildForceInvokeFactory&&this.options.buildForceInvokeFactory[e])}isDuplicateMessageIgnoredFor(e){return this.ignoreDuplicateModulesMap.hasOwnProperty(e)}getConfigForModule(e){if(this.options.config)return this.options.config[e]}shouldCatchError(){return this.options.catchError}shouldRecordStats(){return this.options.recordStats}onError(e){this.options.onError(e)}}}(AMDLoader=AMDLoader||{}),function(p){class t{constructor(e){this._env=e,this._scriptLoader=null,this._callbackMap={}}load(e,t,r,i){this._scriptLoader||(this._env.isWebWorker?this._scriptLoader=new s:this._env.isElectronRenderer?(o=e.getConfig().getOptionsLiteral()[\"preferScriptTags\"],this._scriptLoader=o?new n:new f(this._env)):this._env.isNode?this._scriptLoader=new f(this._env):this._scriptLoader=new n);var o={callback:r,errorback:i};this._callbackMap.hasOwnProperty(t)?this._callbackMap[t].push(o):(this._callbackMap[t]=[o],this._scriptLoader.load(e,t,()=>this.triggerCallback(t),e=>this.triggerErrorback(t,e)))}triggerCallback(e){let t=this._callbackMap[e];delete this._callbackMap[e];for(let e=0;e<t.length;e++)t[e].callback()}triggerErrorback(e,t){let r=this._callbackMap[e];delete this._callbackMap[e];for(let e=0;e<r.length;e++)r[e].errorback(t)}}class n{attachListeners(e,t,r){let i=()=>{e.removeEventListener(\"load\",o),e.removeEventListener(\"error\",n)},o=e=>{i(),t()},n=e=>{i(),r(e)};e.addEventListener(\"load\",o),e.addEventListener(\"error\",n)}load(o,n,s,l){if(/^node\\|/.test(n)){let e=o.getConfig().getOptionsLiteral(),t=_(o.getRecorder(),e.nodeRequire||p.global.nodeRequire),r=n.split(\"|\"),i=null;try{i=t(r[1])}catch(e){return void l(e)}o.enqueueDefineAnonymousModule([],()=>i),s()}else{let e=document.createElement(\"script\");e.setAttribute(\"async\",\"async\"),e.setAttribute(\"type\",\"text/javascript\"),this.attachListeners(e,s,l);const t=o.getConfig().getOptionsLiteral()[\"trustedTypesPolicy\"];t&&(n=t.createScriptURL(n)),e.setAttribute(\"src\",n);s=o.getConfig().getOptionsLiteral()[\"cspNonce\"];s&&e.setAttribute(\"nonce\",s),document.getElementsByTagName(\"head\")[0].appendChild(e)}}}class s{constructor(){this._cachedCanUseEval=null}_canUseEval(e){return null===this._cachedCanUseEval&&(this._cachedCanUseEval=function(e){const t=e.getConfig().getOptionsLiteral()[\"trustedTypesPolicy\"];try{return(t?self.eval(t.createScript(\"\",\"true\")):new Function(\"true\")).call(self),!0}catch{return!1}}(e)),this._cachedCanUseEval}load(t,r,i,o){if(/^node\\|/.test(r)){const n=t.getConfig().getOptionsLiteral(),s=_(t.getRecorder(),n.nodeRequire||p.global.nodeRequire),l=r.split(\"|\");let e=null;try{e=s(l[1])}catch(e){return void o(e)}t.enqueueDefineAnonymousModule([],function(){return e}),i()}else{const d=t.getConfig().getOptionsLiteral()[\"trustedTypesPolicy\"];if(/^((http:)|(https:)|(file:))/.test(r)&&r.substring(0,self.origin.length)!==self.origin||!this._canUseEval(t))try{d&&(r=d.createScriptURL(r)),importScripts(r),i()}catch(e){o(e)}else fetch(r).then(e=>{if(200!==e.status)throw new Error(e.statusText);return e.text()}).then(e=>{e=e+`\\n//# sourceURL=`+r,(d?self.eval(d.createScript(\"\",e)):new Function(e)).call(self),i()}).then(void 0,o)}}}class f{constructor(e){this._env=e,this._didInitialize=!1,this._didPatchNodeRequire=!1}_init(e){this._didInitialize||(this._didInitialize=!0,this._fs=e(\"fs\"),this._vm=e(\"vm\"),this._path=e(\"path\"),this._crypto=e(\"crypto\"))}_initNodeRequire(e,f){const _=f.getConfig().getOptionsLiteral()[\"nodeCachedData\"];if(_&&!this._didPatchNodeRequire){this._didPatchNodeRequire=!0;const m=this,y=e(\"module\");function g(r){const i=r.constructor;function e(e){return r.require(e)}return(e.resolve=function(e,t){return i._resolveFilename(e,r,!1,t)}).paths=function(e){return i._resolveLookupPaths(e,r)},e.main=process.mainModule,e.extensions=i._extensions,e.cache=i._cache,e}y.prototype._compile=function(e,t){const r=y.wrap(e.replace(/^#!.*/,\"\")),i=f.getRecorder(),o=m._getCachedDataPath(_,t),n={filename:t};let s;try{const p=m._fs.readFileSync(o);s=p.slice(0,16),n.cachedData=p.slice(16),i.record(60,o)}catch{i.record(61,o)}const l=new m._vm.Script(r,n),d=l.runInThisContext(n),a=m._path.dirname(t),u=g(this),c=[this.exports,u,this,t,a,process,_commonjsGlobal,Buffer],h=d.apply(this.exports,c);return m._handleCachedData(l,r,o,!n.cachedData,f),m._verifyCachedData(l,r,o,s,f),h}}}load(n,r,s,l){const e=n.getConfig().getOptionsLiteral(),i=_(n.getRecorder(),e.nodeRequire||p.global.nodeRequire),d=e.nodeInstrumenter||function(e){return e};this._init(i),this._initNodeRequire(i,n);var t=n.getRecorder();if(/^node\\|/.test(r)){let e=r.split(\"|\"),t=null;try{t=i(e[1])}catch(e){return void l(e)}n.enqueueDefineAnonymousModule([],()=>t),s()}else{r=p.Utilities.fileUriToFilePath(this._env.isWindows,r);const a=this._path.normalize(r),u=this._getElectronRendererScriptPathOrUri(a),c=!!e.nodeCachedData,h=c?this._getCachedDataPath(e.nodeCachedData,r):void 0;this._readSourceAndCachedData(a,h,t,(t,r,i,o)=>{if(t)l(t);else{let e;e=r.charCodeAt(0)===f._BOM?f._PREFIX+r.substring(1)+f._SUFFIX:f._PREFIX+r+f._SUFFIX,e=d(e,a);t={filename:u,cachedData:i},r=this._createAndEvalScript(n,e,t,s,l);this._handleCachedData(r,e,h,c&&!i,n),this._verifyCachedData(r,e,h,o,n)}})}}_createAndEvalScript(e,t,r,i,o){const n=e.getRecorder(),s=(n.record(31,r.filename),new this._vm.Script(t,r)),l=s.runInThisContext(r),d=e.getGlobalAMDDefineFunc();let a=!1;function u(){return a=!0,d.apply(null,arguments)}return u.amd=d.amd,l.call(p.global,e.getGlobalAMDRequireFunc(),u,r.filename,this._path.dirname(r.filename)),n.record(32,r.filename),a?i():o(new Error(`Didn't receive define call in ${r.filename}!`)),s}_getElectronRendererScriptPathOrUri(e){if(!this._env.isElectronRenderer)return e;let t=e.match(/^([a-z])\\:(.*)/i);return t?\"file:///\"+(t[1].toUpperCase()+\":\"+t[2]).replace(/\\\\/g,\"/\"):\"file://\"+e}_getCachedDataPath(e,t){var r=this._crypto.createHash(\"md5\").update(t,\"utf8\").update(e.seed,\"utf8\").update(process.arch,\"\").digest(\"hex\"),t=this._path.basename(t).replace(/\\.js$/,\"\");return this._path.join(e.path,t+`-${r}.code`)}_handleCachedData(t,r,i,e,o){t.cachedDataRejected?this._fs.unlink(i,e=>{o.getRecorder().record(62,i),this._createAndWriteCachedData(t,r,i,o),e&&o.getConfig().onError(e)}):e&&this._createAndWriteCachedData(t,r,i,o)}_createAndWriteCachedData(t,r,i,o){let e=Math.ceil(o.getConfig().getOptionsLiteral().nodeCachedData.writeDelay*(1+Math.random())),n=-1,s=0,l;const d=()=>{setTimeout(()=>{l=l||this._crypto.createHash(\"md5\").update(r,\"utf8\").digest();var e=t.createCachedData();0===e.length||e.length===n||5<=s||(e.length<n?d():(n=e.length,this._fs.writeFile(i,Buffer.concat([l,e]),e=>{e&&o.getConfig().onError(e),o.getRecorder().record(63,i),d()})))},e*Math.pow(4,s++))};d()}_readSourceAndCachedData(e,n,s,l){if(n){let r,i,o,t=2;const d=e=>{e?l(e):0==--t&&l(void 0,r,i,o)};this._fs.readFile(e,{encoding:\"utf8\"},(e,t)=>{r=t,d(e)}),this._fs.readFile(n,(e,t)=>{!e&&t&&0<t.length?(o=t.slice(0,16),i=t.slice(16),s.record(60,n)):s.record(61,n),d()})}else this._fs.readFile(e,{encoding:\"utf8\"},l)}_verifyCachedData(e,t,r,i,o){!i||e.cachedDataRejected||setTimeout(()=>{var e=this._crypto.createHash(\"md5\").update(t,\"utf8\").digest();i.equals(e)||(o.getConfig().onError(new Error(`FAILED TO VERIFY CACHED DATA, deleting stale '${r}' now, but a RESTART IS REQUIRED`)),this._fs.unlink(r,e=>{e&&o.getConfig().onError(e)}))},Math.ceil(5e3*(1+Math.random())))}}function _(t,r){if(r.__$__isRecorded)return r;function e(e){t.record(33,e);try{return r(e)}finally{t.record(34,e)}}return e.__$__isRecorded=!0,e}f._BOM=65279,f._PREFIX=\"(function (require, define, __filename, __dirname) { \",f._SUFFIX=`\\n});`,p.ensureRecordedNodeRequire=_,p.createScriptLoader=function(e){return new t(e)}}(AMDLoader=AMDLoader||{}),function(n){class d{constructor(e){var t=e.lastIndexOf(\"/\");this.fromModulePath=-1!==t?e.substr(0,t+1):\"\"}static _normalizeModuleId(e){let t=e,r;for(r=/\\/\\.\\//;r.test(t);)t=t.replace(r,\"/\");for(t=t.replace(/^\\.\\//g,\"\"),r=/\\/(([^\\/])|([^\\/][^\\/\\.])|([^\\/\\.][^\\/])|([^\\/][^\\/][^\\/]+))\\/\\.\\.\\//;r.test(t);)t=t.replace(r,\"/\");return t=t.replace(/^(([^\\/])|([^\\/][^\\/\\.])|([^\\/\\.][^\\/])|([^\\/][^\\/][^\\/]+))\\/\\.\\.\\//,\"\")}resolveModule(e){let t=e;return n.Utilities.isAbsolutePath(t)||(n.Utilities.startsWith(t,\"./\")||n.Utilities.startsWith(t,\"../\"))&&(t=d._normalizeModuleId(this.fromModulePath+t)),t}}d.ROOT=new d(\"\"),n.ModuleIdResolver=d;class a{constructor(e,t,r,i,o,n){this.id=e,this.strId=t,this.dependencies=r,this._callback=i,this._errorback=o,this.moduleIdResolver=n,this.exports={},this.error=null,this.exportsPassedIn=!1,this.unresolvedDependenciesCount=this.dependencies.length,this._isComplete=!1}static _safeInvokeFunction(e,t){try{return{returnedValue:e.apply(n.global,t),producedError:null}}catch(e){return{returnedValue:null,producedError:e}}}static _invokeFactory(e,t,r,i){return e.shouldInvokeFactory(t)?e.shouldCatchError()?this._safeInvokeFunction(r,i):{returnedValue:r.apply(n.global,i),producedError:null}:{returnedValue:null,producedError:null}}complete(e,t,r,i){this._isComplete=!0;let o=null;if(this._callback&&(\"function\"==typeof this._callback?(e.record(21,this.strId),r=a._invokeFactory(t,this.strId,this._callback,r),o=r.producedError,e.record(22,this.strId),!o&&typeof r.returnedValue<\"u\"&&(!this.exportsPassedIn||n.Utilities.isEmpty(this.exports))&&(this.exports=r.returnedValue)):this.exports=this._callback),o){let e=n.ensureError(o);e.phase=\"factory\",e.moduleId=this.strId,e.neededBy=i(this.id),this.error=e,t.onError(e)}this.dependencies=null,this._callback=null,this._errorback=null,this.moduleIdResolver=null}onDependencyError(e){return this._isComplete=!0,this.error=e,!!this._errorback&&(this._errorback(e),!0)}isComplete(){return this._isComplete}}n.Module=a;class s{constructor(){this._nextId=0,this._strModuleIdToIntModuleId=new Map,this._intModuleIdToStrModuleId=[],this.getModuleId(\"exports\"),this.getModuleId(\"module\"),this.getModuleId(\"require\")}getMaxModuleId(){return this._nextId}getModuleId(e){let t=this._strModuleIdToIntModuleId.get(e);return\"u\"<typeof t&&(t=this._nextId++,this._strModuleIdToIntModuleId.set(e,t),this._intModuleIdToStrModuleId[t]=e),t}getStrModuleId(e){return this._intModuleIdToStrModuleId[e]}}class u{constructor(e){this.id=e}}u.EXPORTS=new u(0),u.MODULE=new u(1),u.REQUIRE=new u(2),n.RegularDependency=u;class l{constructor(e,t,r){this.id=e,this.pluginId=t,this.pluginParam=r}}n.PluginDependency=l;class c{constructor(e,t,r,i,o=0){this._env=e,this._scriptLoader=t,this._loaderAvailableTimestamp=o,this._defineFunc=r,this._requireFunc=i,this._moduleIdProvider=new s,this._config=new n.Configuration(this._env),this._hasDependencyCycle=!1,this._modules2=[],this._knownModules2=[],this._inverseDependencies2=[],this._inversePluginDependencies2=new Map,this._currentAnonymousDefineCall=null,this._recorder=null,this._buildInfoPath=[],this._buildInfoDefineStack=[],this._buildInfoDependencies=[],this._requireFunc.moduleManager=this}reset(){return new c(this._env,this._scriptLoader,this._defineFunc,this._requireFunc,this._loaderAvailableTimestamp)}getGlobalAMDDefineFunc(){return this._defineFunc}getGlobalAMDRequireFunc(){return this._requireFunc}static _findRelevantLocationInStack(e,t){let o=e=>e.replace(/\\\\/g,\"/\"),n=o(e),r=t.split(/\\n/);for(let e=0;e<r.length;e++){var s=r[e].match(/(.*):(\\d+):(\\d+)\\)?$/);if(s){let e=s[1],t=s[2],r=s[3],i=Math.max(e.lastIndexOf(\" \")+1,e.lastIndexOf(\"(\")+1);if((e=o(e=e.substr(i)))===n){let e={line:parseInt(t,10),col:parseInt(r,10)};return 1===e.line&&(e.col-=53),e}}}throw new Error(\"Could not correlate define call site for needle \"+e)}getBuildInfo(){if(!this._config.isBuild())return null;let r=[],i=0;for(let e=0,t=this._modules2.length;e<t;e++){var o,n,s,l=this._modules2[e];l&&(o=this._buildInfoPath[l.id]||null,n=this._buildInfoDefineStack[l.id]||null,s=this._buildInfoDependencies[l.id],r[i++]={id:l.strId,path:o,defineLocation:o&&n?c._findRelevantLocationInStack(o,n):null,dependencies:s,shim:null,exports:l.exports})}return r}getRecorder(){return this._recorder||(this._config.shouldRecordStats()?this._recorder=new n.LoaderEventRecorder(this._loaderAvailableTimestamp):this._recorder=n.NullLoaderEventRecorder.INSTANCE),this._recorder}getLoaderEvents(){return this.getRecorder().getEvents()}enqueueDefineAnonymousModule(e,t){if(null!==this._currentAnonymousDefineCall)throw new Error(\"Can only have one anonymous define call per script file\");let r=null;this._config.isBuild()&&(r=new Error(\"StackLocation\").stack||null),this._currentAnonymousDefineCall={stack:r,dependencies:e,callback:t}}defineModule(t,r,i,o,n,s=new d(t)){var l=this._moduleIdProvider.getModuleId(t);if(this._modules2[l])this._config.isDuplicateMessageIgnoredFor(t)||console.warn(\"Duplicate definition of module '\"+t+\"'\");else{let e=new a(l,t,this._normalizeDependencies(r,s),i,o,s);this._modules2[l]=e,this._config.isBuild()&&(this._buildInfoDefineStack[l]=n,this._buildInfoDependencies[l]=(e.dependencies||[]).map(e=>this._moduleIdProvider.getStrModuleId(e.id))),this._resolve(e)}}_normalizeDependency(e,t){if(\"exports\"===e)return u.EXPORTS;if(\"module\"===e)return u.MODULE;if(\"require\"===e)return u.REQUIRE;var r,i,o=e.indexOf(\"!\");return 0<=o?(i=t.resolveModule(e.substr(0,o)),o=t.resolveModule(e.substr(o+1)),r=this._moduleIdProvider.getModuleId(i+\"!\"+o),i=this._moduleIdProvider.getModuleId(i),new l(r,i,o)):new u(this._moduleIdProvider.getModuleId(t.resolveModule(e)))}_normalizeDependencies(r,i){let o=[],n=0;for(let e=0,t=r.length;e<t;e++)o[n++]=this._normalizeDependency(r[e],i);return o}_relativeRequire(e,t,r,i){if(\"string\"==typeof t)return this.synchronousRequire(t,e);this.defineModule(n.Utilities.generateAnonymousModule(),t,r,i,null,e)}synchronousRequire(e,t=new d(e)){let r=this._normalizeDependency(e,t),i=this._modules2[r.id];if(!i)throw new Error(\"Check dependency list! Synchronous require cannot resolve module '\"+e+\"'. This is the first mention of this module!\");if(!i.isComplete())throw new Error(\"Check dependency list! Synchronous require cannot resolve module '\"+e+\"'. This module has not been resolved completely yet.\");if(i.error)throw i.error;return i.exports}configure(e,t){var r=this._config.shouldRecordStats();this._config=t?new n.Configuration(this._env,e):this._config.cloneAndMerge(e),this._config.shouldRecordStats()&&!r&&(this._recorder=null)}getConfig(){return this._config}_onLoad(e){var t;null!==this._currentAnonymousDefineCall&&(t=this._currentAnonymousDefineCall,this._currentAnonymousDefineCall=null,this.defineModule(this._moduleIdProvider.getStrModuleId(e),t.dependencies,t.callback,null,t.stack))}_createLoadError(e,t){var r=this._moduleIdProvider.getStrModuleId(e),e=(this._inverseDependencies2[e]||[]).map(e=>this._moduleIdProvider.getStrModuleId(e));const i=n.ensureError(t);return i.phase=\"loading\",i.moduleId=r,i.neededBy=e,i}_onLoadError(e,t){var r=this._createLoadError(e,t);this._modules2[e]||(this._modules2[e]=new a(e,this._moduleIdProvider.getStrModuleId(e),[],()=>{},null,null));let i=[];for(let e=0,t=this._moduleIdProvider.getMaxModuleId();e<t;e++)i[e]=!1;let o=!1,n=[];for(n.push(e),i[e]=!0;0<n.length;){let e=n.shift(),t=this._modules2[e];t&&(o=t.onDependencyError(r)||o);var s=this._inverseDependencies2[e];if(s)for(let e=0,t=s.length;e<t;e++){var l=s[e];i[l]||(n.push(l),i[l]=!0)}}o||this._config.onError(r)}_hasDependencyPath(e,r){var t=this._modules2[e];if(!t)return!1;let i=[];for(let e=0,t=this._moduleIdProvider.getMaxModuleId();e<t;e++)i[e]=!1;let o=[];for(o.push(t),i[e]=!0;0<o.length;){var n=o.shift().dependencies;if(n)for(let e=0,t=n.length;e<t;e++){var s=n[e];if(s.id===r)return!0;var l=this._modules2[s.id];l&&!i[s.id]&&(i[s.id]=!0,o.push(l))}}return!1}_findCyclePath(r,i,o){if(r===i||50===o)return[r];var e=this._modules2[r];if(!e)return null;var n=e.dependencies;if(n)for(let t=0,e=n.length;t<e;t++){let e=this._findCyclePath(n[t].id,i,o+1);if(null!==e)return e.push(r),e}return null}_createRequire(i){var e=(e,t,r)=>this._relativeRequire(i,e,t,r);return e.toUrl=e=>this._config.requireToUrl(i.resolveModule(e)),e.getStats=()=>this.getLoaderEvents(),e.hasDependencyCycle=()=>this._hasDependencyCycle,e.config=(e,t=!1)=>{this.configure(e,t)},e.__$__nodeRequire=n.global.nodeRequire,e}_loadModule(s){if(!this._modules2[s]&&!this._knownModules2[s]){this._knownModules2[s]=!0;let e=this._moduleIdProvider.getStrModuleId(s),i=this._config.moduleIdToPaths(e),o=(this._env.isNode&&(-1===e.indexOf(\"/\")||/^@[^\\/]+\\/[^\\/]+$/.test(e))&&i.push(\"node|\"+e),-1),n=e=>{if(++o>=i.length)this._onLoadError(s,e);else{let t=i[o],r=this.getRecorder();if(this._config.isBuild()&&\"empty:\"===t)return this._buildInfoPath[s]=t,this.defineModule(this._moduleIdProvider.getStrModuleId(s),[],null,null,null),void this._onLoad(s);r.record(10,t),this._scriptLoader.load(this,t,()=>{\"empty:\"!==t&&(this._buildInfoPath[s]=t),r.record(11,t),this._onLoad(s)},e=>{r.record(12,t),n(e)})}};n(null)}}_loadPluginDependency(e,t){var r;this._modules2[t.id]||this._knownModules2[t.id]||(this._knownModules2[t.id]=!0,(r=e=>{this.defineModule(this._moduleIdProvider.getStrModuleId(t.id),[],e,null,null)}).error=e=>{this._config.onError(this._createLoadError(t.id,e))},e.load(t.pluginParam,this._createRequire(d.ROOT),r,this._config.getOptionsLiteral()))}_resolve(r){var i=r.dependencies;if(i)for(let e=0,t=i.length;e<t;e++){var o=i[e];if(o===u.EXPORTS)r.exportsPassedIn=!0,r.unresolvedDependenciesCount--;else if(o===u.MODULE)r.unresolvedDependenciesCount--;else if(o===u.REQUIRE)r.unresolvedDependenciesCount--;else{let e=this._modules2[o.id];if(e&&e.isComplete()){if(e.error)return void r.onDependencyError(e.error);r.unresolvedDependenciesCount--}else if(this._hasDependencyPath(o.id,r.id)){this._hasDependencyCycle=!0,console.warn(\"There is a dependency cycle between '\"+this._moduleIdProvider.getStrModuleId(o.id)+\"' and '\"+this._moduleIdProvider.getStrModuleId(r.id)+\"'. The cyclic path follows:\");let e=this._findCyclePath(o.id,r.id,0)||[];e.reverse(),e.push(o.id),console.warn(e.map(e=>this._moduleIdProvider.getStrModuleId(e)).join(` => \\n`)),r.unresolvedDependenciesCount--}else if(this._inverseDependencies2[o.id]=this._inverseDependencies2[o.id]||[],this._inverseDependencies2[o.id].push(r.id),o instanceof l){let e=this._modules2[o.pluginId];if(e&&e.isComplete()){this._loadPluginDependency(e.exports,o);continue}let t=this._inversePluginDependencies2.get(o.pluginId);t||(t=[],this._inversePluginDependencies2.set(o.pluginId,t)),t.push(o),this._loadModule(o.pluginId)}else this._loadModule(o.id)}}0===r.unresolvedDependenciesCount&&this._onModuleComplete(r)}_onModuleComplete(o){var e=this.getRecorder();if(!o.isComplete()){let r=o.dependencies,i=[];if(r)for(let e=0,t=r.length;e<t;e++){var n=r[e];n===u.EXPORTS?i[e]=o.exports:n===u.MODULE?i[e]={id:o.strId,config:()=>this._config.getConfigForModule(o.strId)}:n===u.REQUIRE?i[e]=this._createRequire(o.moduleIdResolver):(n=this._modules2[n.id],i[e]=n?n.exports:null)}o.complete(e,this._config,i,e=>(this._inverseDependencies2[e]||[]).map(e=>this._moduleIdProvider.getStrModuleId(e)));var s=this._inverseDependencies2[o.id];if(this._inverseDependencies2[o.id]=null,s)for(let r=0,e=s.length;r<e;r++){let e=s[r],t=this._modules2[e];t.unresolvedDependenciesCount--,0===t.unresolvedDependenciesCount&&this._onModuleComplete(t)}var l=this._inversePluginDependencies2.get(o.id);if(l){this._inversePluginDependencies2.delete(o.id);for(let e=0,t=l.length;e<t;e++)this._loadPluginDependency(o.exports,l[e])}}}}n.ModuleManager=c}(AMDLoader=AMDLoader||{}),function(t){const r=new t.Environment;let i=null;function o(e,t,r){\"string\"!=typeof e&&(r=t,t=e,e=null),\"object\"==typeof t&&Array.isArray(t)||(r=t,t=null),t=t||[\"require\",\"exports\",\"module\"],e?i.defineModule(e,t,r,null,null):i.enqueueDefineAnonymousModule(t,r)}function e(e,t=!1){i.configure(e,t)}function n(){if(1===arguments.length){if(arguments[0]instanceof Object&&!Array.isArray(arguments[0]))return void e(arguments[0]);if(\"string\"==typeof arguments[0])return i.synchronousRequire(arguments[0])}if(2!==arguments.length&&3!==arguments.length||!Array.isArray(arguments[0]))throw new Error(\"Unrecognized require call\");i.defineModule(t.Utilities.generateAnonymousModule(),arguments[0],arguments[1],arguments[2],null)}o.amd={jQuery:!0};function s(){var e;(typeof t.global.require<\"u\"||typeof require<\"u\")&&\"function\"==typeof(e=t.global.require||require)&&\"function\"==typeof e.resolve&&(e=t.ensureRecordedNodeRequire(i.getRecorder(),e),t.global.nodeRequire=e,n.nodeRequire=e,n.__$__nodeRequire=e),!r.isNode||r.isElectronRenderer||r.isElectronNodeIntegrationWebWorker?(r.isElectronRenderer||(t.global.define=o),t.global.require=n):module.exports=n}n.config=e,n.getConfig=function(){return i.getConfig().getOptionsLiteral()},n.reset=function(){i=i.reset()},n.getBuildInfo=function(){return i.getBuildInfo()},n.getStats=function(){return i.getLoaderEvents()},n.define=o,t.init=s,\"function\"==typeof t.global.define&&t.global.define.amd||(i=new t.ModuleManager(r,t.createScriptLoader(r),o,n,t.Utilities.getHighPerformanceTimestamp()),typeof t.global.require<\"u\"&&\"function\"!=typeof t.global.require&&n.config(t.global.require),(define=function(){return o.apply(null,arguments)}).amd=o.amd,\"u\"<typeof doNotInitLoader&&s())}(AMDLoader=AMDLoader||{});"
)

;; -------------------- 2. HTML 结构与核心渲染 --------------------

(defconst json-cmp--html-template
  (concat
   "<!DOCTYPE html>
<html>
<head>
    <meta charset=\"utf-8\">
    <title>JSON Compare</title>
    <style>
        body, html { margin: 0; padding: 0; width: 100vw; height: 100vh; overflow: hidden; background: #1e1e1e; font-family: sans-serif; }
        #container { display: flex; position: absolute; top: 0; left: 0; right: 0; bottom: 20px; }
        #left-pane, #right-pane { flex: 1; height: 100%; overflow: hidden; position: relative; }
        #left-pane { border-right: 1px solid #3e3e3e; }
        #status-bar { position: absolute; bottom: 0; left: 0; right: 0; height: 20px; background: #2d2d2d; color: #cccccc; display: flex; align-items: center; padding: 0 16px; font-size: 12px; border-top: 1px solid #3e3e3e; gap: 16px; z-index: 100; }
        .diff-row-left { background-color: rgba(255, 0, 0, 0.15) !important; }
        .diff-row-right { background-color: rgba(0, 255, 0, 0.1) !important; }
        .diff-char-left { background-color: rgba(255, 0, 0, 0.4) !important; }
        .diff-char-right { background-color: rgba(0, 255, 0, 0.3) !important; }
        .status-error { color: #f48771; } .status-ok { color: #89e185; } .status-info { color: #888888; }
        /* Vim 状态栏样式 */
        .vim-status {
            position: absolute; bottom: 0; background: #007acc; color: white;
            padding: 2px 10px; font-size: 11px; font-weight: bold; z-index: 1000;
            border-top-left-radius: 4px; border-top-right-radius: 4px;
            box-shadow: 0 -2px 4px rgba(0,0,0,0.3); font-family: monospace;
            min-height: 14px;
        }
        #vim-left { left: 0px; }
        #vim-right { right: 32px; }
    </style>
</head>
<body>
    <div id=\"container\">
        <div id=\"left-pane\"><div id=\"vim-left\" class=\"vim-status\"></div></div>
        <div id=\"right-pane\"><div id=\"vim-right\" class=\"vim-status\"></div></div>
    </div>
    <div id=\"status-bar\"><span id=\"status-message\">正在初始化...</span><span id=\"diff-count\" style=\"display:none;\"></span></div>
    <script>"
   json-cmp--source-map-js
   json-cmp--json-patch-js
   json-cmp--monaco-loader-js
   "</script>

    <script>
        require.config({
            paths: {
                'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.43.0/min/vs',
                'monaco-vim': 'https://unpkg.com/monaco-vim@0.4.0/dist/monaco-vim'
            }
        });

        require(['vs/editor/editor.main'], function() {
            // 在 Monaco 加载完毕后，再加载 monaco-vim 插件
            require(['monaco-vim'], function(MonacoVim) {
                window.leftEditor = monaco.editor.create(document.getElementById('left-pane'), {
                    theme: 'vs-dark', language: 'json', automaticLayout: true, minimap: { enabled: false }, scrollBeyondLastLine: false
                });
                window.rightEditor = monaco.editor.create(document.getElementById('right-pane'), {
                    theme: 'vs-dark', language: 'json', automaticLayout: true, minimap: { enabled: false }, scrollBeyondLastLine: false
                });

                // 初始化 Vim 模式并绑定状态栏
                MonacoVim.initVimMode(window.leftEditor, document.getElementById('vim-left'));
                MonacoVim.initVimMode(window.rightEditor, document.getElementById('vim-right'));

                let lDecs = [], rDecs = [];

                let isSyncingLeft = false, isSyncingRight = false;
                leftEditor.onDidScrollChange((e) => {
                    if (isSyncingLeft) { isSyncingLeft = false; return; }
                    isSyncingRight = true;
                    rightEditor.setScrollTop(e.scrollTop);
                    rightEditor.setScrollLeft(e.scrollLeft);
                });
                rightEditor.onDidScrollChange((e) => {
                    if (isSyncingRight) { isSyncingRight = false; return; }
                    isSyncingLeft = true;
                    leftEditor.setScrollTop(e.scrollTop);
                    leftEditor.setScrollLeft(e.scrollLeft);
                });

                function getFocused() {
                    return rightEditor.hasTextFocus() || rightEditor.hasWidgetFocus() ? rightEditor : leftEditor;
                }
                function copyToClipboard(text) {
                    var ta = document.createElement('textarea');
                    ta.value = text; ta.style.position = 'absolute'; ta.style.left = '-9999px';
                    document.body.appendChild(ta);
                    ta.select();
                    try { document.execCommand('copy'); } catch(e) {}
                    document.body.removeChild(ta);
                }

                document.addEventListener('keydown', function(e) {
                    if (!(e.metaKey || e.ctrlKey)) return;
                    const k = e.key.toLowerCase();
                    if (k === 'v') {
                        e.preventDefault();
                        document.title = 'EMACS_PASTE_' + (getFocused() === rightEditor ? 'RIGHT' : 'LEFT');
                    } else if (k === 'c' || k === 'x') {
                        let ed = getFocused(), sel = ed.getSelection();
                        let text = sel.isEmpty() ? (ed.getModel().getLineContent(sel.startLineNumber) + '\\n') : ed.getModel().getValueInRange(sel);
                        if (text) {
                            e.preventDefault();
                            copyToClipboard(text);
                            if (k === 'x') {
                                let range = sel.isEmpty() ? new monaco.Range(sel.startLineNumber, 1, sel.startLineNumber + 1, 1) : sel;
                                ed.executeEdits('cut', [{range: range, text: ''}]);
                            }
                        }
                    }
                }, true);

                window.emacsForcePaste = function(side, text) {
                    let ed = (side === 'left') ? leftEditor : rightEditor;
                    let sel = ed.getSelection();
                    ed.executeEdits('emacs-paste', [{
                        range: (sel && !sel.isEmpty()) ? sel : ed.getModel().getFullModelRange(),
                        text: text
                    }]);
                    ed.focus(); compare();
                };

                function findIntraDiff(s1, s2) {
                    let i = 0, j = s1.length - 1, k = s2.length - 1;
                    while (i <= j && i <= k && s1[i] === s2[i]) i++;
                    while (j >= i && k >= i && s1[j] === s2[k]) { j--; k--; }
                    return { start: i, end1: j + 1, end2: k + 1 };
                }

                function offsetToPos(startLine, startCol, text, offset) {
                    let line = startLine, col = startCol;
                    for (let i = 0; i < offset; i++) {
                        if (text.charCodeAt(i) === 10) { line++; col = 1; }
                        else { col++; }
                    }
                    return { line: line, column: col };
                }

                function compare() {
                    const lt = leftEditor.getValue();
                    const rt = rightEditor.getValue();
                    const msg = document.getElementById('status-message');
                    const cnt = document.getElementById('diff-count');
                    if (!lt.trim() && !rt.trim()) { clearHighlights(); msg.textContent = '等待输入...'; msg.className = 'status-info'; cnt.style.display = 'none'; return; }
                    if (!lt.trim() || !rt.trim()) { clearHighlights(); msg.textContent = (lt.trim() ? '右侧' : '左侧') + '为空，等待输入...'; msg.className = 'status-info'; cnt.style.display = 'none'; return; }
                    try {
                        const lm = window.jsonSourceMap.parse(lt), rm = window.jsonSourceMap.parse(rt);
                        const diffs = window.jsonpatch.compare(lm.data, rm.data);
                        if (diffs.length === 0) {
                            clearHighlights();
                            msg.textContent = 'JSON 语义一致'; msg.className = 'status-ok'; cnt.style.display = 'none';
                        } else {
                            let effectiveCount = applyHighlights(diffs, lm, rm, lt, rt);
                            msg.textContent = '检测到语义差异'; msg.className = 'status-error';
                            cnt.textContent = '(共 ' + effectiveCount + ' 处)'; cnt.style.display = 'inline';
                        }
                    } catch(e) {
                        msg.textContent = 'JSON 格式错误: ' + e.message; msg.className = 'status-error'; cnt.style.display = 'none';
                    }
                }

                function applyHighlights(diffs, lm, rm, lt, rt) {
                    let nl = [], nr = [];
                    let adds = diffs.filter(d => d.op === 'add');
                    let rems = diffs.filter(d => d.op === 'remove');
                    let others = diffs.filter(d => d.op !== 'add' && d.op !== 'remove');
                    let paired = [];
                    let usedAdds = new Set(), usedRems = new Set();

                    for (let i = 0; i < rems.length; i++) {
                        let r = rems[i];
                        for (let j = 0; j < adds.length; j++) {
                            if (usedAdds.has(j)) continue;
                            let a = adds[j];
                            if (r.path.substring(0, r.path.lastIndexOf('/')) === a.path.substring(0, a.path.lastIndexOf('/'))) {
                                let lp = lm.pointers[r.path], rp = rm.pointers[a.path];
                                if (lp && rp && lp.key && rp.key) {
                                    if (lt.substring(lp.value.pos, lp.valueEnd.pos) === rt.substring(rp.value.pos, rp.valueEnd.pos)) {
                                        paired.push({ lp: lp, rp: rp });
                                        usedRems.add(i); usedAdds.add(j);
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    for (let i = 0; i < rems.length; i++) { if (!usedRems.has(i)) others.push(rems[i]); }
                    for (let j = 0; j < adds.length; j++) { if (!usedAdds.has(j)) others.push(adds[j]); }

                    function addRowBg(p, arr, cls) {
                        let start = p.key || p.value;
                        arr.push({ range: new monaco.Range(start.line+1, 1, p.valueEnd.line+1, 1), options: { className: cls, isWholeLine: true }});
                    }

                    paired.forEach(pair => {
                        let lp = pair.lp, rp = pair.rp;
                        addRowBg(lp, nl, 'diff-row-left'); addRowBg(rp, nr, 'diff-row-right');
                        let k1 = lt.substring(lp.key.pos, lp.keyEnd.pos);
                        let k2 = rt.substring(rp.key.pos, rp.keyEnd.pos);
                        let id = findIntraDiff(k1, k2);

                        if (id.start < id.end1) {
                            let p1 = offsetToPos(lp.key.line+1, lp.key.column+1, k1, id.start);
                            let p2 = offsetToPos(lp.key.line+1, lp.key.column+1, k1, id.end1);
                            nl.push({ range: new monaco.Range(p1.line, p1.column, p2.line, p2.column), options: { className: 'diff-char-left' }});
                        }
                        if (id.start < id.end2) {
                            let p1 = offsetToPos(rp.key.line+1, rp.key.column+1, k2, id.start);
                            let p2 = offsetToPos(rp.key.line+1, rp.key.column+1, k2, id.end2);
                            nr.push({ range: new monaco.Range(p1.line, p1.column, p2.line, p2.column), options: { className: 'diff-char-right' }});
                        }
                    });

                    others.forEach(d => {
                        const lp = lm.pointers[d.path], rp = rm.pointers[d.path];
                        if (lp) addRowBg(lp, nl, 'diff-row-left');
                        if (rp) addRowBg(rp, nr, 'diff-row-right');

                        if (lp && rp && d.op === 'replace') {
                            const v1 = lt.substring(lp.value.pos, lp.valueEnd.pos);
                            const v2 = rt.substring(rp.value.pos, rp.valueEnd.pos);
                            const id = findIntraDiff(v1, v2);

                            if (id.start < id.end1) {
                                let p1 = offsetToPos(lp.value.line+1, lp.value.column+1, v1, id.start);
                                let p2 = offsetToPos(lp.value.line+1, lp.value.column+1, v1, id.end1);
                                nl.push({ range: new monaco.Range(p1.line, p1.column, p2.line, p2.column), options: { className: 'diff-char-left' }});
                            }
                            if (id.start < id.end2) {
                                let p1 = offsetToPos(rp.value.line+1, rp.value.column+1, v2, id.start);
                                let p2 = offsetToPos(rp.value.line+1, rp.value.column+1, v2, id.end2);
                                nr.push({ range: new monaco.Range(p1.line, p1.column, p2.line, p2.column), options: { className: 'diff-char-right' }});
                            }
                        } else {
                            if (lp) {
                                let start = lp.key || lp.value;
                                nl.push({ range: new monaco.Range(start.line+1, start.column+1, lp.valueEnd.line+1, lp.valueEnd.column+1), options: { className: 'diff-char-left' }});
                            }
                            if (rp) {
                                let start = rp.key || rp.value;
                                nr.push({ range: new monaco.Range(start.line+1, start.column+1, rp.valueEnd.line+1, rp.valueEnd.column+1), options: { className: 'diff-char-right' }});
                            }
                        }
                    });
                    lDecs = leftEditor.deltaDecorations(lDecs, nl);
                    rDecs = rightEditor.deltaDecorations(rDecs, nr);
                    return diffs.length - paired.length;
                }

                function clearHighlights() {
                    lDecs = leftEditor.deltaDecorations(lDecs, []);
                    rDecs = rightEditor.deltaDecorations(rDecs, []);
                }

                let t;
                leftEditor.onDidChangeModelContent(() => { clearTimeout(t); t = setTimeout(compare, 300); });
                rightEditor.onDidChangeModelContent(() => { clearTimeout(t); t = setTimeout(compare, 300); });
                document.getElementById('status-message').textContent = '就绪';
            });
        });
    </script>
</body>
</html>"))

;; -------------------- 3. Emacs 接口 --------------------

(defun json-cmp--poll-title-signal ()
  (when (buffer-live-p json-cmp--session-buffer)
    (let* ((xw (with-current-buffer json-cmp--session-buffer (xwidget-webkit-current-session)))
           (title (when xw (xwidget-webkit-title xw))))
      (when (and title (string-prefix-p "EMACS_PASTE_" title))
        (let ((side (if (string-match "RIGHT" title) "right" "left"))
              (text (or (gui-get-selection 'CLIPBOARD) (ignore-errors (current-kill 0 t)) "")))
          (with-current-buffer json-cmp--session-buffer
            (xwidget-webkit-execute-script xw "document.title = 'JSON Compare';")
            (xwidget-webkit-execute-script xw (format "if(window.emacsForcePaste) window.emacsForcePaste('%s', %s);" side (json-encode-string text)))))))))

(defun json-cmp--cleanup ()
  (when json-cmp--signal-timer (cancel-timer json-cmp--signal-timer) (setq json-cmp--signal-timer nil)))

;;;###autoload
(defun json-cmp ()
  (interactive)
  (unless (featurep 'xwidget-internal) (error "需要 Xwidgets 支持"))
  (let ((temp-file (make-temp-file "json-cmp-" nil ".html")))
    (with-temp-file temp-file (insert json-cmp--html-template))
    (delete-other-windows)
    (xwidget-webkit-browse-url (concat "file://" temp-file))
    (setq json-cmp--session-buffer (current-buffer))
    (rename-buffer "*JSON-Compare*" t)
    (with-current-buffer json-cmp--session-buffer
      (setq header-line-format nil)
      (setq mode-line-format nil))
    (add-hook 'kill-buffer-hook #'json-cmp--cleanup nil t)
    (json-cmp--cleanup)
    (setq json-cmp--signal-timer (run-with-timer 0.1 0.1 #'json-cmp--poll-title-signal))))

(provide 'json-cmp)
