import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';

const { chromium } = await import(pathToFileURL(`${process.env.PLAYWRIGHT_MODULE}/index.mjs`).href);
const browser = await chromium.launch({headless:true,args:['--no-sandbox','--enable-webgl','--use-gl=angle','--use-angle=swiftshader']});

async function waitForGodotBridge(page){
  await page.waitForFunction(()=>{
    const frame=document.getElementById('game')?.contentWindow;
    return Boolean(frame && typeof frame.__evilWizardInput==='function' && frame.document?.querySelector('canvas'));
  },null,{timeout:60000});
}

try {
  const phoneContext=await browser.newContext({
    viewport:{width:844,height:390},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1'
  });
  const phone=await phoneContext.newPage();
  const phoneErrors=[];phone.on('pageerror',e=>phoneErrors.push(String(e)));
  await phone.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});

  assert.equal(await phone.locator('#menu').isVisible(),true,'Phone must open at the game menu');
  assert.equal(await phone.locator('[data-screen]').count(),4,'Game menu must expose Play, Controls, Settings, and How to Play');
  assert.equal(await phone.locator('#champion option').count(),15,'Play screen must expose all champions');
  assert.match(await phone.locator('#device').textContent(),/Phone \/ tablet/i,'Phone must auto-detect touch mode');

  await phone.locator('[data-screen="controls"]').click();
  assert.equal(await phone.locator('#screen-controls').isVisible(),true,'Controls must be a real menu screen');
  assert.equal(await phone.locator('#touch-map select').count(),8,'Every virtual controller action position must be remappable');
  assert.equal(await phone.locator('#keyboard-map select').count(),9,'Keyboard gameplay actions must be remappable');
  assert.equal(await phone.locator('#gamepad-map select').count(),9,'Physical gamepad actions must be remappable');

  await phone.locator('#touch-style').selectOption('playstation');
  await phone.locator('#touch-size').selectOption('compact');
  await phone.locator('#touch-opacity').fill('54');
  const south=phone.locator('#touch-map .mapping-row').filter({hasText:'South face'}).locator('select');
  await south.selectOption('attack');

  await phone.locator('[data-screen="settings"]').click();
  assert.equal(await phone.locator('#screen-settings').isVisible(),true,'Settings must be a real menu screen');
  await phone.locator('#difficulty').selectOption('story');
  await phone.locator('#master-volume').fill('55');
  await phone.locator('#brightness').fill('115');
  await phone.locator('#camera-shake').uncheck();

  await phone.locator('[data-screen="how"]').click();
  assert.match(await phone.locator('#screen-how').textContent(),/Explore.*Fight.*Interact/s,'How to Play must explain the game loop');
  await phone.locator('[data-guide="playstation"]').click();
  assert.match(await phone.locator('#guide-text').textContent(),/PlayStation controller/i,'How to Play must include PlayStation controls');

  await phone.locator('[data-screen="play"]').click();
  await phone.locator('#champion').selectOption('warrior');
  await Promise.all([phone.waitForURL(/\/console\.html\?/),phone.locator('#start').click()]);

  assert.equal(await phone.locator('.orientation-gate').isVisible(),false,'Landscape phone must immediately show gameplay');
  assert.equal(await phone.locator('.screen-bezel').count(),0,'No virtual console frame may surround the game');
  assert.equal(await phone.locator('.dpad').count(),0,'Phone/tablet overlay must not contain a virtual D-pad');
  assert.equal(await phone.locator('.left-zone').isVisible(),true,'Joystick-only left zone must float over the game');
  assert.equal(await phone.locator('.right-zone').isVisible(),true,'Controller-style face buttons must float over the game');
  assert.equal(await phone.locator('.top-left').isVisible(),true,'Left shoulder/trigger controls must float over the game');
  assert.equal(await phone.locator('.top-right').isVisible(),true,'Right shoulder/trigger controls must float over the game');
  assert.equal(await phone.locator('#touch-stage').getAttribute('data-style'),'playstation','Touch controller appearance choice must persist');
  assert.equal(await phone.locator('[data-position="south"]').getAttribute('data-action'),'attack','Virtual face-button remap must persist');

  const psDisplay=await phone.locator('[data-position="south"] .ps-label').evaluate(el=>getComputedStyle(el).display);
  const xboxDisplay=await phone.locator('[data-position="south"] .xbox-label').evaluate(el=>getComputedStyle(el).display);
  assert.notEqual(psDisplay,'none','PlayStation symbols must be visible in PlayStation mode');
  assert.equal(xboxDisplay,'none','Xbox labels must hide in PlayStation mode');

  const layout=await phone.evaluate(()=>{
    const game=document.getElementById('game').getBoundingClientRect();
    const joy=document.getElementById('joystick').getBoundingClientRect();
    const face=document.querySelector('.right-zone').getBoundingClientRect();
    const south=document.querySelector('[data-position="south"]').getBoundingClientRect();
    const shoulder=document.querySelector('[data-position="l1"]').getBoundingClientRect();
    const center=document.elementFromPoint(innerWidth/2,innerHeight/2);
    return {game:{w:game.width,h:game.height},joy:{x:joy.x,right:joy.right,w:joy.width},face:{x:face.x,right:face.right},south:{w:south.width,h:south.height},shoulder:{w:shoulder.width,h:shoulder.height},vw:innerWidth,vh:innerHeight,centerId:center?.id||'',filter:getComputedStyle(document.getElementById('game')).filter,alpha:getComputedStyle(document.documentElement).getPropertyValue('--alpha')};
  });
  assert.equal(Math.round(layout.game.w),layout.vw,'Game must remain full viewport behind controls');
  assert.equal(Math.round(layout.game.h),layout.vh,'Game must remain full viewport behind controls');
  assert(layout.joy.right<layout.vw*.31,'Left joystick must stay near the left edge');
  assert(layout.face.x>layout.vw*.66,'Face controls must stay near the right edge');
  assert(layout.joy.w>=112,'Phone joystick must be gamepad-scale and easy to acquire');
  assert(layout.south.w>=54&&layout.south.h>=54,'Phone face buttons must be large gamepad-style touch targets');
  assert(layout.shoulder.h>=36,'Phone shoulder controls must be easy to hit');
  assert.equal(layout.centerId,'game','Center of gameplay must remain unobstructed');
  assert.match(layout.filter,/brightness\(1\.15\)/,'Brightness setting must apply to touch game');

  await waitForGodotBridge(phone);
  await phone.waitForFunction(()=>/Opening story|INTERACT/.test(document.getElementById('status')?.textContent||''),null,{timeout:10000});
  await phone.evaluate(()=>{
    const frame=document.getElementById('game').contentWindow;
    window.__audit=[];const original=frame.__evilWizardInput;
    frame.__evilWizardInput=function(message){window.__audit.push(JSON.parse(message));return original(message)};
  });
  await phone.locator('[data-position="south"]').click();
  await phone.waitForFunction(()=>window.__audit.some(m=>m.action==='attack'&&m.pressed===true));
  await phone.waitForFunction(()=>window.__audit.some(m=>m.action==='attack'&&m.pressed===false));

  const joy=await phone.locator('#joystick').boundingBox(),attack=await phone.locator('[data-position="south"]').boundingBox();
  const mid=b=>({x:Math.round(b.x+b.width/2),y:Math.round(b.y+b.height/2)}),j=mid(joy),a=mid(attack);
  const cdp=await phoneContext.newCDPSession(phone);
  const first={x:j.x+Math.round(joy.width*.22),y:j.y,id:1},second={x:a.x,y:a.y,id:2};
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[first]});
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[first,second]});
  await phone.waitForFunction(()=>window.__audit.some(m=>m.action==='move_right'&&m.pressed)&&window.__audit.some(m=>m.action==='attack'&&m.pressed));
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[first]});
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  assert.equal(await phone.evaluate(()=>window.visualViewport?.scale??1),1,'Simultaneous touch must not zoom the browser');
  await phone.screenshot({path:'build/handheld-console-preview.png'});
  assert.equal(phoneErrors.length,0,`Phone browser errors: ${phoneErrors.join('; ')}`);
  await phoneContext.close();

  // Facebook Messenger / Facebook in-app browser: launch the Godot canvas top-level.
  // The game must not depend on fullscreen, orientation locking, or the external console shell here.
  const messengerContext=await browser.newContext({
    viewport:{width:844,height:390},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 [FBAN/MessengerForiOS;FBAV/530.0.0.0.0]'
  });
  const messenger=await messengerContext.newPage();
  const messengerErrors=[];messenger.on('pageerror',e=>messengerErrors.push(String(e)));
  await messenger.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.equal(await messenger.locator('#menu').isVisible(),true,'Messenger must still show the normal setup menu');
  await messenger.locator('#champion').selectOption('warrior');
  await Promise.all([
    messenger.waitForURL(/\/index\.html\?.*ew_launch=1/,{timeout:15000}),
    messenger.locator('#start').click()
  ]);
  assert.match(messenger.url(),/hero=warrior/,'Compatibility launch must carry the selected champion');
  assert.equal(await messenger.locator('#touch-stage').count(),0,'Messenger must not use the external console shell');
  await messenger.waitForSelector('canvas',{timeout:60000});
  await messenger.waitForFunction(()=>typeof window.__evilWizardInput==='function',null,{timeout:60000});
  assert.equal(await messenger.evaluate(()=>window.parent===window),true,'Messenger compatibility mode must run top-level');
  assert.equal(messengerErrors.length,0,`Messenger browser errors: ${messengerErrors.join('; ')}`);
  await messengerContext.close();

  const messengerPortraitContext=await browser.newContext({
    viewport:{width:393,height:852},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 [FBAN/MessengerForiOS;FBAV/530.0.0.0.0]'
  });
  const messengerPortrait=await messengerPortraitContext.newPage();
  const messengerPortraitErrors=[];messengerPortrait.on('pageerror',e=>messengerPortraitErrors.push(String(e)));
  await messengerPortrait.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  await messengerPortrait.locator('#champion').selectOption('warrior');
  await Promise.all([
    messengerPortrait.waitForURL(/\/index\.html\?.*ew_launch=1/,{timeout:15000}),
    messengerPortrait.locator('#start').click()
  ]);
  await messengerPortrait.waitForSelector('canvas',{timeout:60000});
  await messengerPortrait.waitForFunction(()=>typeof window.__evilWizardInput==='function',null,{timeout:60000});
  await messengerPortrait.waitForFunction(()=>getComputedStyle(document.body).touchAction==='none',null,{timeout:10000});
  const fbPortrait=await messengerPortrait.evaluate(()=>{
    const canvas=document.querySelector('canvas').getBoundingClientRect();
    const meta=document.querySelector('meta[name="viewport"]')?.getAttribute('content')||'';
    return {canvas:{x:canvas.x,y:canvas.y,w:canvas.width,h:canvas.height},iw:innerWidth,ih:innerHeight,scale:visualViewport?.scale??1,touch:getComputedStyle(document.body).touchAction,meta};
  });
  assert.equal(fbPortrait.touch,'none','Direct Messenger launch must disable browser touch gestures');
  assert.match(fbPortrait.meta,/maximum-scale=1/,'Direct Messenger launch must lock page scale');
  assert.equal(fbPortrait.scale,1,'Direct Messenger portrait launch must start at normal scale');
  assert(fbPortrait.canvas.w>0&&fbPortrait.canvas.h>0,'Direct Messenger portrait launch must render the game canvas');
  const fbCdp=await messengerPortraitContext.newCDPSession(messengerPortrait);
  await fbCdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:80,y:700,id:1},{x:320,y:700,id:2}]});
  await fbCdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  assert.equal(await messengerPortrait.evaluate(()=>visualViewport?.scale??1),1,'Direct Messenger multi-touch must not zoom the page');
  assert.equal(messengerPortraitErrors.length,0,`Messenger portrait errors: ${messengerPortraitErrors.join('; ')}`);
  await messengerPortraitContext.close();

  const portraitContext=await browser.newContext({
    viewport:{width:393,height:852},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1'
  });
  const portrait=await portraitContext.newPage();
  const portraitErrors=[];portrait.on('pageerror',e=>portraitErrors.push(String(e)));
  await portrait.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.equal(await portrait.locator('#menu').isVisible(),true,'Portrait phone must see the normal game menu');
  assert.equal(await portrait.locator('.orientation-gate').count(),0,'Main menu must never force orientation');
  await Promise.all([portrait.waitForURL(/\/console\.html\?/),portrait.locator('#start').click()]);
  assert.equal(await portrait.locator('#game').isVisible(),true,'Portrait phone must keep the game visible after Start');
  assert.equal(await portrait.locator('#joystick').isVisible(),true,'Portrait phone must keep the joystick visible');
  assert.equal(await portrait.locator('.right-zone').isVisible(),true,'Portrait phone must keep face controls visible');
  assert.equal(await portrait.locator('.orientation-gate').isVisible(),false,'Portrait compatibility mode must never cover gameplay');
  const portraitFit=await portrait.evaluate(()=>{
    const game=document.getElementById('game').getBoundingClientRect();
    const joy=document.getElementById('joystick').getBoundingClientRect();
    const face=document.querySelector('.right-zone').getBoundingClientRect();
    const rotate=getComputedStyle(document.querySelector('.orientation-gate')).display;
    return {game:{w:game.width,h:game.height},joy:{x:joy.x,y:joy.y,right:joy.right,bottom:joy.bottom},face:{x:face.x,y:face.y,right:face.right,bottom:face.bottom},iw:innerWidth,ih:innerHeight,rotate};
  });
  assert.equal(Math.round(portraitFit.game.w),portraitFit.iw,'Portrait game must fill viewport width');
  assert.equal(Math.round(portraitFit.game.h),portraitFit.ih,'Portrait game must fill viewport height');
  assert(portraitFit.joy.x>=0&&portraitFit.joy.right<=portraitFit.iw&&portraitFit.joy.y>=0&&portraitFit.joy.bottom<=portraitFit.ih,'Portrait joystick must stay on-screen');
  assert(portraitFit.face.x>=0&&portraitFit.face.right<=portraitFit.iw&&portraitFit.face.y>=0&&portraitFit.face.bottom<=portraitFit.ih,'Portrait face controls must stay on-screen');
  assert.equal(portraitFit.rotate,'none','Portrait rotate overlay must stay disabled');
  assert.equal(portraitErrors.length,0,`Portrait browser errors: ${portraitErrors.join('; ')}`);
  await portraitContext.close();

  const deckContext=await browser.newContext({
    viewport:{width:1280,height:800},hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (X11; Linux x86_64; Steam Deck) AppleWebKit/537.36 Chrome/140 Safari/537.36'
  });
  const deck=await deckContext.newPage();
  await deck.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.equal(await deck.locator('#menu').isVisible(),true,'Gaming handheld must start at main menu');
  assert.match(await deck.locator('#device').textContent(),/Gaming handheld/i,'Steam Deck must use physical-control mode');
  await deck.locator('#start').click();
  await deck.waitForFunction(()=>document.getElementById('menu').hidden===true);
  assert.equal(await deck.locator('.controls').count(),0,'Gaming handheld must never generate virtual controls');
  assert.equal(await deck.locator('.orientation-gate').count(),0,'Gaming handheld must never ask for rotation');
  await deckContext.close();

  const desktopContext=await browser.newContext({viewport:{width:1365,height:768},hasTouch:false,deviceScaleFactor:1});
  const desktop=await desktopContext.newPage();
  const desktopErrors=[];desktop.on('pageerror',e=>desktopErrors.push(String(e)));
  await desktop.goto('http://127.0.0.1:8765/play.html?mode=keyboard',{waitUntil:'domcontentloaded'});
  assert.equal(await desktop.locator('#menu').isVisible(),true,'Desktop must begin at main menu');
  await desktop.locator('[data-screen="controls"]').click();
  await desktop.locator('[data-control-pane="keyboard"]').click();
  const jumpRow=desktop.locator('#keyboard-map .mapping-row').filter({hasText:'Jump'}).locator('select');
  await jumpRow.selectOption('74');
  await desktop.locator('[data-screen="settings"]').click();
  await desktop.locator('#master-volume').fill('65');
  await desktop.locator('[data-screen="play"]').click();
  await desktop.locator('#start').click();
  await desktop.waitForFunction(()=>document.getElementById('menu').hidden===true);
  assert.equal(await desktop.locator('.controls').count(),0,'Desktop must have no virtual controller overlay');
  const fit=await desktop.evaluate(()=>{const r=document.getElementById('game').getBoundingClientRect();return{x:r.x,y:r.y,w:r.width,h:r.height,iw:innerWidth,ih:innerHeight}});
  assert.equal(fit.x,0);assert.equal(fit.y,0);assert.equal(Math.round(fit.w),fit.iw);assert.equal(Math.round(fit.h),fit.ih);
  assert.equal(desktopErrors.length,0,`Desktop browser errors: ${desktopErrors.join('; ')}`);
  await desktopContext.close();

  console.log('Browser passed: menu/remapping, landscape and portrait touch play, Messenger top-level compatibility, zoom lock, physical handheld mode, and desktop mode.');
} finally {
  await browser.close();
}
