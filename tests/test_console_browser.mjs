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
  // Phone/tablet: setup first, then floating controls in landscape.
  const mobileContext=await browser.newContext({
    viewport:{width:844,height:390},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1'
  });
  const mobile=await mobileContext.newPage();
  const mobileErrors=[];mobile.on('pageerror',e=>mobileErrors.push(String(e)));
  await mobile.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.equal(await mobile.locator('#setup').isVisible(),true,'Phone must open at setup menu');
  assert.match(await mobile.locator('#guide-text').textContent(),/floating stick/i,'Phone auto mode must show touch control guide');
  assert.equal(await mobile.locator('#touch-options').isVisible(),true,'Phone auto mode must expose touch layout options');
  assert.equal(await mobile.locator('#champion option').count(),15,'Setup menu must expose all champions');
  assert.match(await mobile.locator('#detected').textContent(),/Phone \/ tablet/i,'Phone must be detected as touch mode');

  await mobile.locator('#champion').selectOption('warrior');
  await Promise.all([
    mobile.waitForURL(/\/console\.html\?/),
    mobile.locator('#start').click()
  ]);
  assert.equal(await mobile.locator('.orientation-gate').isVisible(),false,'Landscape phone must not show rotate gate');
  assert.equal(await mobile.locator('#game').getAttribute('src'),'./index.html','Touch shell must host the real exported game');
  assert.equal(await mobile.locator('.move-cluster').isVisible(),true,'Floating movement cluster must be visible');
  assert.equal(await mobile.locator('.action-cluster').isVisible(),true,'Floating action cluster must be visible');
  assert.equal(await mobile.locator('.screen-bezel').count(),0,'Legacy hardware console frame must be gone');

  const layout=await mobile.evaluate(()=>{
    const game=document.getElementById('game').getBoundingClientRect();
    const joy=document.getElementById('joystick').getBoundingClientRect();
    const attack=document.querySelector('[data-action="attack"]').getBoundingClientRect();
    const center=document.elementFromPoint(innerWidth/2,innerHeight/2);
    return {
      game:{x:game.x,y:game.y,w:game.width,h:game.height},
      joy:{x:joy.x,right:joy.right,w:joy.width},
      attack:{x:attack.x,right:attack.right,w:attack.width},
      viewport:{w:innerWidth,h:innerHeight},
      centerId:center?.id||'',centerTag:center?.tagName||''
    };
  });
  assert.equal(Math.round(layout.game.w),layout.viewport.w,'Touch game must fill viewport width');
  assert.equal(Math.round(layout.game.h),layout.viewport.h,'Touch game must fill viewport height');
  assert(layout.joy.right<layout.viewport.w*.28,'Movement controls must stay at extreme edge');
  assert(layout.attack.x>layout.viewport.w*.66,'Action controls must stay at extreme edge');
  assert(layout.joy.w<=100,'Compact phone joystick must remain small');
  assert(layout.attack.w<=44,'Compact phone action buttons must remain small');
  assert.equal(layout.centerId,'game','Center gameplay view must remain unobstructed');

  await waitForGodotBridge(mobile);
  await mobile.waitForFunction(()=>/Opening story|Move with/.test(document.getElementById('status')?.textContent||''),null,{timeout:10000});
  await mobile.evaluate(()=>{
    const frame=document.getElementById('game').contentWindow;
    window.__consoleAudit=[];
    const original=frame.__evilWizardInput;
    frame.__evilWizardInput=function(message){window.__consoleAudit.push(JSON.parse(message));return original(message)};
  });
  await mobile.locator('[data-action="attack"]').click();
  await mobile.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='attack'&&m.pressed===true));
  await mobile.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='attack'&&m.pressed===false));

  const joy=await mobile.locator('#joystick').boundingBox(),attack=await mobile.locator('[data-action="attack"]').boundingBox();
  const center=b=>({x:Math.round(b.x+b.width/2),y:Math.round(b.y+b.height/2)}),j=center(joy),a=center(attack);
  const cdps=await mobileContext.newCDPSession(mobile);
  const first={x:j.x+Math.round(joy.width*.22),y:j.y,id:1},second={x:a.x,y:a.y,id:2};
  await cdps.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[first]});
  await cdps.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[first,second]});
  await mobile.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='move_right'&&m.pressed)&&window.__consoleAudit.some(m=>m.action==='attack'&&m.pressed));
  await cdps.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[first]});
  await cdps.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  assert.equal(await mobile.evaluate(()=>window.visualViewport?.scale??1),1,'Touch gameplay must not zoom page');
  await mobile.screenshot({path:'build/handheld-console-preview.png'});
  assert.equal(mobileErrors.length,0,`Phone browser JS errors: ${mobileErrors.join('; ')}`);
  await mobileContext.close();

  // Portrait phone: setup first; rotate request appears only after Start.
  const portraitContext=await browser.newContext({
    viewport:{width:393,height:852},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1'
  });
  const portrait=await portraitContext.newPage();
  await portrait.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.equal(await portrait.locator('#setup').isVisible(),true,'Portrait phone must show setup before any rotate request');
  assert.equal(await portrait.locator('.orientation-gate').count(),0,'Launcher itself must not demand rotation');
  await Promise.all([portrait.waitForURL(/\/console\.html\?/),portrait.locator('#start').click()]);
  assert.equal(await portrait.locator('.orientation-gate').isVisible(),true,'Phone must ask for landscape only after Start');
  assert.equal(await portrait.locator('#touch-stage').isVisible(),false,'Touch game must stay hidden behind portrait gate');
  await portrait.setViewportSize({width:852,height:393});
  await portrait.waitForFunction(()=>getComputedStyle(document.querySelector('.orientation-gate')).display==='none');
  assert.equal(await portrait.locator('#touch-stage').isVisible(),true,'Rotating phone must reveal full-screen game');
  assert.equal(await portrait.locator('.action-cluster').isVisible(),true,'Rotating phone must reveal floating controls');
  await portraitContext.close();

  // Gaming handheld: physical controls, no virtual console and no rotate gate.
  const deckContext=await browser.newContext({
    viewport:{width:1280,height:800},hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (X11; Linux x86_64; Steam Deck) AppleWebKit/537.36 Chrome/140 Safari/537.36'
  });
  const deck=await deckContext.newPage();
  await deck.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.equal(await deck.locator('#setup').isVisible(),true,'Gaming handheld must still begin at setup');
  assert.match(await deck.locator('#detected').textContent(),/Physical gamepad|Gaming handheld/i,'Steam Deck must resolve to physical controls');
  assert.equal(await deck.locator('#touch-options').isVisible(),false,'Gaming handheld must not expose touch-console sizing');
  await deck.locator('#start').click();
  await deck.waitForFunction(()=>document.getElementById('setup').hidden===true);
  assert.match(deck.url(),/\/play\.html$/,'Gaming handheld must stay on physical launcher');
  assert.equal(await deck.locator('.controls').count(),0,'Gaming handheld must have no virtual controls');
  assert.equal(await deck.locator('.orientation-gate').count(),0,'Gaming handheld must never get phone rotate gate');
  await deckContext.close();

  // Desktop / large display: setup first, then full viewport physical-control game.
  const desktopContext=await browser.newContext({viewport:{width:1365,height:768},hasTouch:false,deviceScaleFactor:1});
  const desktop=await desktopContext.newPage();
  const desktopErrors=[];desktop.on('pageerror',e=>desktopErrors.push(String(e)));
  const response=await desktop.goto('http://127.0.0.1:8765/play.html?mode=keyboard',{waitUntil:'domcontentloaded'});
  assert.equal(response.status(),200);
  assert.equal(await desktop.locator('#setup').isVisible(),true,'Desktop must begin at setup menu');
  assert.match(await desktop.locator('#guide-text').textContent(),/left click attack/i,'Desktop setup must explain keyboard and mouse');
  assert.equal(await desktop.locator('.controls').count(),0,'Desktop launcher must have no virtual controls');
  await desktop.locator('#start').click();
  await desktop.waitForFunction(()=>document.getElementById('setup').hidden===true);
  assert.equal(await desktop.locator('#game').getAttribute('src'),'./index.html','Desktop must load exported game after setup');
  const fit=await desktop.evaluate(()=>{
    const r=document.getElementById('game').getBoundingClientRect();
    return {x:r.x,y:r.y,w:r.width,h:r.height,iw:innerWidth,ih:innerHeight};
  });
  assert.equal(fit.x,0);assert.equal(fit.y,0);assert.equal(Math.round(fit.w),fit.iw);assert.equal(Math.round(fit.h),fit.ih);
  assert.equal(await desktop.locator('.orientation-gate').count(),0,'Desktop must never get rotate gate');
  assert.equal(desktopErrors.length,0,`Desktop browser JS errors: ${desktopErrors.join('; ')}`);
  await desktopContext.close();

  // Manual controller mode documents both major console controller families.
  const padContext=await browser.newContext({viewport:{width:1600,height:900},hasTouch:false});
  const pad=await padContext.newPage();
  await pad.goto('http://127.0.0.1:8765/play.html?mode=gamepad',{waitUntil:'domcontentloaded'});
  assert.match(await pad.locator('#guide-text').textContent(),/Left stick|D-pad/,'Gamepad mode must show controller guide');
  await pad.locator('[data-guide="playstation"]').click();
  assert.match(await pad.locator('#guide-text').textContent(),/Cross jump.*Circle dash.*Square attack.*Triangle heavy/i,'PlayStation guide must be available');
  await padContext.close();

  console.log('Browser passed: setup-first launch, floating phone controls, post-start rotate gate, clear center gameplay, physical-control gaming handhelds, desktop fullscreen layout, and Xbox/PlayStation guides.');
} finally {
  await browser.close();
}
