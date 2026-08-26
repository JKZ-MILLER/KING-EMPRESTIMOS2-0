const CACHE="king-control-v50";
self.addEventListener("install",e=>self.skipWaiting());
self.addEventListener("activate",e=>e.waitUntil(self.clients.claim()));
self.addEventListener("notificationclick",e=>{
  e.notification.close();
  e.waitUntil(clients.matchAll({type:"window",includeUncontrolled:true}).then(list=>{
    for(const c of list){if("focus" in c)return c.focus()}
    return clients.openWindow(e.notification.data?.url||"./");
  }));
});
self.addEventListener("push",e=>{
  let d={};
  try{d=e.data?e.data.json():{}}catch(_){d={body:e.data?.text?.()||"Novo pagamento registrado"}}
  e.waitUntil(self.registration.showNotification(d.title||"Pagamento aprovado",{
    body:d.body||"Um pagamento foi registrado",
    icon:"./logo-ce.png",badge:"./logo-ce.png",tag:d.tag||"kc-payment",data:{url:"./"}
  }));
});