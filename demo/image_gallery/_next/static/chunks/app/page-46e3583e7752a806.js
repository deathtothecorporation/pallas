(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[931],{3279:function(e,t,a){Promise.resolve().then(a.bind(a,8836))},8836:function(e,t,a){"use strict";a.r(t),a.d(t,{default:function(){return o}});var r=a(3827),n=a(4090);function o(){let[e,t]=(0,n.useState)([]),[a,o]=(0,n.useState)([]),[s,l]=(0,n.useState)([]),[c,i]=(0,n.useState)([]),[m,d]=(0,n.useState)(0),[g,f]=(0,n.useState)(0),[u,h]=(0,n.useState)(!1),[p,x]=(0,n.useState)(!1),[y,w]=(0,n.useState)(""),[b,j]=(0,n.useState)("Welcome to my frame"),[v,N]=(0,n.useState)("");(0,n.useEffect)(()=>{let e=window.location.protocol,t=window.location.hostname,a=window.location.port;N("".concat(e,"//").concat(t).concat(a?":".concat(a):""))},[]),(0,n.useEffect)(()=>{["startImages"].forEach(e=>{localStorage.getItem(e)||localStorage.setItem(e,JSON.stringify([]))})},[]),(0,n.useEffect)(()=>{console.log("start useEffect");let e=async()=>{i(await Promise.all(s.map(async e=>{try{let t=await B(e,"start"),a=URL.createObjectURL(t);return{name:e,preview:a}}catch(e){return console.error(e),null}})))};s.length!==m&&(e(),d(s.length))},[s,m]),(0,n.useEffect)(()=>{["imagesImages"].forEach(e=>{localStorage.getItem(e)||localStorage.setItem(e,JSON.stringify([]))})},[]),(0,n.useEffect)(()=>{console.log("images useEffect");let t=async()=>{o(await Promise.all(e.map(async e=>{try{let t=await B(e,"images"),a=URL.createObjectURL(t);return{name:e,preview:a}}catch(e){return console.error(e),null}})))};e.length!==g&&(t(),f(e.length))},[e,g]);let S=(e,t,a)=>r=>{Array.from(r.target.files).forEach(r=>{if(r instanceof Blob){let n=new FileReader;n.onload=()=>{let o=new Blob([n.result],{type:r.type});(function(e,t,a,r){let n=indexedDB.open("imageDB",1);n.onupgradeneeded=e=>{let t=e.target.result;t.objectStoreNames.contains("images")||t.createObjectStore("images",{keyPath:["name","category"]})},n.onsuccess=n=>{n.target.result.transaction(["images"],"readwrite").objectStore("images").put({name:t,category:a,data:e}).onsuccess=()=>{r(!0)}},n.onerror=e=>{console.error("Database error: ",e.target.errorCode),r(!1)}})(o,r.name,a,n=>{if(n){console.log("Successfully saved blob for ".concat(r.name," to IndexedDB")," to ".concat(a,". blob: ").concat(o," "));let n=[...e,r.name];t(n),localStorage.setItem("".concat(a,"Images"),JSON.stringify(n))}else console.error("Failed to save ".concat(r.name," to IndexedDB"))})},n.onerror=e=>{console.error("Error reading file:",e)},n.readAsArrayBuffer(r)}else console.error("The provided value is not a Blob or File.")}),r.target.value=""},I=(e,t,a,n,o,s)=>(0,r.jsx)("div",{className:"shrink grid grid-cols-1 md:grid-cols-2 gap-8",children:Array(e).fill(null).map((e,l)=>{let c=t[l],i=a[l];return(0,r.jsx)("div",{className:"upload-placeholder",children:c&&i?(0,r.jsxs)("div",{className:"image-container",children:[(0,r.jsx)("img",{src:i.preview,alt:"Preview ".concat(l),className:"upload-image-preview"}),(0,r.jsx)("div",{className:"hidden relative",children:(0,r.jsx)("button",{className:"absolute bottom-2 opacity-70",onClick:()=>E(l,t,a,n,o,s),children:"Remove"})})]}):(0,r.jsxs)("label",{htmlFor:"image-upload-".concat(s,"-").concat(l),children:[(0,r.jsx)("span",{className:"underline cursor-pointer",children:"+ Add Image"}),(0,r.jsx)("input",{type:"file",id:"image-upload-".concat(s,"-").concat(l),style:{display:"none"},onChange:S(t,n,s),multiple:!0,accept:"image/png, image/jpeg"})]})},l)})}),E=(e,t,a,r,n,o)=>{let s=[...t],l=[...a],[c]=s.splice(e,1),[i]=l.splice(e,1);r(s),n(l),localStorage.setItem("".concat(o,"Images"),JSON.stringify(s)),(null==i?void 0:i.preview)&&URL.revokeObjectURL(i.preview),k(c,o)},k=(e,t)=>{let a=indexedDB.open("imageDB",1);a.onsuccess=a=>{a.target.result.transaction(["images"],"readwrite").objectStore("images").delete([e,t])},a.onerror=e=>{console.error("Error deleting image from IndexedDB:",e.target.error)}},B=(e,t)=>new Promise((a,r)=>{let n=indexedDB.open("imageDB",1);n.onsuccess=n=>{let o=n.target.result.transaction(["images"],"readonly").objectStore("images");console.log("getting ".concat(e," from ").concat(t));let s=o.get([e,t]);s.onsuccess=()=>{var t;let n=null===(t=s.result)||void 0===t?void 0:t.data;n?a(n):r("Image data for ".concat(e," not found in IndexedDB."))},s.onerror=()=>{r("Error fetching image from IndexedDB")}},n.onerror=e=>{console.error("Database error: ",e.target.errorCode),r("Database error")}});async function D(e,t,a){let r=await e.arrayBuffer();try{let n=await fetch("".concat(v).concat(t,"/").concat(a),{method:"PUT",headers:{"Content-Type":e.type,authorization:y},body:r});n.ok?console.log("Upload successful for ".concat(a)):console.error("Error uploading ".concat(a,": "),n.statusText)}catch(e){console.error("Error uploading ".concat(a,": "),e)}}async function F(){x(!0),console.log("generateAndUploadAll starting..."),await C(),await O(),h(!0),x(!1),console.log("generateAndUploadAll done!")}async function C(){console.log("generateAllHtml starting...");let t=[],a="".concat(v,"/framer"),r='\n            <!DOCTYPE html>\n        <html lang="en">\n        <head>\n          <meta charset="UTF-8">\n          <meta name="viewport" content="width=device-width, initial-scale=1.0">\n          <meta property="og:image" content="'.concat(a,'/images/start.png" />\n          <meta property="fc:frame:image" content="').concat(a,'/images/start.png" />\n          <meta property="fc:frame" content="vNext" />\n          <meta property="fc:frame:button:1" content="START" />\n          <meta property="fc:frame:post_url" content="').concat(a,'/start.html" />\n          <title>Image Gallery</title>\n        </head>\n        <body>\n\n            <h1>Image Gallery</h1>\n            <img src="').concat(a,'/images/start.png" alt="start"/>\n            <div>\n              This is a self-hosted image gallery for Farcaster frames is <a href="https://vaporware.network">vaporware</a>.\n            </div>\n        </body>\n        </html>\n      '),n=new Blob([r],{type:"text/html"}),o="start.html";console.log("uploading start page",o);let s=D(n,"/framer",o).then(()=>console.log("uploaded ",o));t.push(s),console.log("uploaded ",o),e.forEach((e,a)=>{let r=U(e),n=function(e){let t="".concat(v,"/framer");return'\n        <!DOCTYPE html>\n        <html lang="en">\n        <head>\n          <meta charset="UTF-8">\n          <meta name="viewport" content="width=device-width, initial-scale=1.0">\n          <meta property="og:image" content="'.concat(t,"/images/").concat(e,'" />\n          <meta property="fc:frame" content="vNext" />\n          <meta property="fc:frame:image" content="').concat(t,"/images/").concat(e,'" />\n          <meta property="fc:frame:button:1" content="<-" />\n          <meta property="fc:frame:button:2" content="Open ^" />\n          <meta property="fc:frame:button:2:action" content="').concat(t,"/images/").concat(e,'" />\n          <meta property="fc:frame:button:3" content="->" />\n          <meta property="fc:frame:post_url" content="').concat(t,"/change/").concat(e,'" />\n          <title>Image Gallery</title>\n        </head>\n        <body>\n            <h1>Image Gallery</h1>\n            <img src="').concat(t,"/images/").concat(e,'" alt="').concat(e,'"/>\n            <div>\n              This is a self-hosted image gallery for Farcaster frames is <a href="https://vaporware.network">vaporware</a>.\n            </div>\n        </body>\n        </html>\n    ')}("".concat(a,".").concat(r)),o=new Blob([n],{type:"text/html"}),s="".concat(a,".html");console.log("uploading ",s);let l=D(o,"/framer",s).then(()=>console.log("uploaded ",s));t.push(l),console.log("uploaded ",s)}),await Promise.all(t),console.log("HTML files generated successfully."),console.log("generateAllHtml done!")}function U(e){let t=e.lastIndexOf(".");return -1!==t&&0!==t?e.substring(t+1):""}async function O(){console.log("get all images starting..."),console.log("images ",e);for(let t=0;t<e.length;t++){console.log("images index ",t);let a=e[t],r=U(a),n=await B(a,"images"),o="".concat(t,".").concat(r);await D(n,"/framer/images",o)}for(let e=0;e<s.length;e++){console.log("start images index ",e);let t=s[e],a=U(t),r=await B(t,"start"),n="start.".concat(a);await D(r,"/framer/images",n)}}return(0,r.jsxs)("div",{className:"container max-w-4xl mx-auto px-4",children:[(0,r.jsxs)("header",{className:"my-12",children:[(0,r.jsx)("p",{children:(0,r.jsx)("span",{className:"font-bold",children:"How to use this:"})}),(0,r.jsxs)("ul",{children:[(0,r.jsxs)("li",{children:["Upload images below. Make sure they conform to the Farcaster Frame requirements.",(0,r.jsxs)("ul",{children:[(0,r.jsx)("li",{children:"PNG, JPG, or GIF"}),(0,r.jsx)("li",{children:"1.91 to 1 aspect ratio"}),(0,r.jsx)("li",{children:"10 MB or less per image"})]})]}),(0,r.jsx)("li",{children:"If you select an incorrect image, refresh the page and start over."}),(0,r.jsx)("li",{children:"Enter the password we provided."}),(0,r.jsx)("li",{children:'Click "Create Frame Link"'}),(0,r.jsx)("li",{children:"Images are first stored locally in your browser, so make sure you upload all 5 before creating the Frame link."})]})]}),(0,r.jsxs)("main",{children:[(0,r.jsxs)("section",{className:"my-12",children:[(0,r.jsx)("h2",{className:"text-xl font-semibold mb-4",children:"Upload the default Frame image."}),(0,r.jsx)("div",{className:"flex flex-col-reverse md:flex-row justify-between items-center md:items-start justify-between",children:I(1,s,c,l,i,"start")})]}),(0,r.jsxs)("section",{className:"my-12",children:[(0,r.jsx)("h2",{className:"text-xl font-semibold mb-4",children:"Upload four gallery images. Files must be 1.91:1 to display correctly"}),(0,r.jsx)("div",{className:"flex flex-col-reverse md:flex-row justify-between items-center md:items-start justify-between",children:I(4,e,a,t,o,"images")})]})]}),(0,r.jsxs)("footer",{className:"mt-24 mb-12 px-4",children:[(0,r.jsx)("div",{className:"flex flex-col md:flex-row md:justify-between items-center md:items-start",children:u?(0,r.jsxs)("div",{className:"shrink flex text-sm max-w-xl flex-col",children:[(0,r.jsx)("div",{className:"mt-8 md:mt-0",children:(0,r.jsx)("span",{className:"break-all",children:"".concat(v,"/framer/start")})}),(0,r.jsx)("div",{children:(0,r.jsx)("p",{className:"mt-4",children:(0,r.jsx)("em",{children:"Copy this link and paste it into a cast to create your Frame."})})})]}):(0,r.jsxs)("div",{children:[(0,r.jsx)("div",{children:(0,r.jsx)("input",{type:"text",className:"mb-4 border-b-2",placeholder:"password",value:y,onChange:e=>w(e.target.value)})}),(0,r.jsx)("div",{className:"grow",children:(0,r.jsx)("button",{disabled:0==y.length||p,onClick:F,children:"Create frame link"})})]})}),(0,r.jsxs)("div",{className:"mt-12",children:["If you're returning here after initially creating the frame and you don't see your url, here's a reminder: ","".concat(v,"/framer/start")]})]})]})}}},function(e){e.O(0,[971,69,744],function(){return e(e.s=3279)}),_N_E=e.O()}]);