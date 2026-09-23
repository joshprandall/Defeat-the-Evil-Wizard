import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';

const { chromium } = await import(pathToFileURL(`${process.env.PLAYWRIGHT_MODULE}/index.mjs`).href);
const browser = await chromium.launch({headless:true,args:['--no-sandbox','--enable-webgl','--use-gl=angle','--use-angle=swiftshader']});
try {
  const mobileContext = await browser.newContext({
    viewport:{width:844,height:390},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 Version/26.0 Mobile/15E148 Safari/604.1'
  });
  const page = await mobileContext.newPage();
  const errors=[];
  page.on('pageerror',error=>errors.push(String(error)));

  await page.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  await page.waitForURL(/\/console\.html$/);
  assert.equal(await page.locator('#game').getAttribute('src'),'./index.html','Mobile/tablet launcher must use handheld console');
  assert.equal(await page.locator('button[data-action]').count(),12,'Movement dpad and action buttons must be visible');
  assert.equal(await page.locator('#joystick').isVisible(),true,'Joystick must be visible');
  assert.equal(await page.locator('#champion-choice option').count(),15,'All champions selectable without tiny game menu');
  assert.equal(await page.locator('#start-champion').isVisible(),true,'Mobile start button must be visible');
  assert.equal(await page.locator('#show-controls').isVisible(),true,'Handheld setup must expose How to Play / Controls before starting');
  await page.locator('#show-controls').click();
  assert.equal(await page.locator('.console-options').getAttribute('open') !== null,true,'How to Play must open the controls dialog');
  assert.match(await page.locator('.console-options').textContent(),/Xbox-compatible controller/,'Controls dialog must document large-screen controller play');
  await page.locator('#console-options-close').click();
  assert.match(await page.locator('meta[name="viewport"]').getAttribute('content'),/maximum-scale=1/,'Mobile shell must lock browser page scale');

  const rails=await page.evaluate(()=>{
    const g=document.getElementById('game').getBoundingClientRect(),l=document.querySelector('.rail.left').getBoundingClientRect(),r=document.querySelector('.rail.right').getBoundingClientRect();
    return {game:{x:g.x,right:g.right,width:g.width},leftRight:l.right,rightX:r.x,body:{w:document.body.scrollWidth,h:document.body.scrollHeight},viewport:{w:innerWidth,h:innerHeight}};
  });
  assert(rails.game.width>150&&rails.leftRight<=rails.game.x&&rails.game.right<=rails.rightX,'Game must be between the independent controller rails');
  assert.equal(rails.body.w,rails.viewport.w,'Handheld shell must not create horizontal page overflow');
  assert.equal(rails.body.h,rails.viewport.h,'Handheld shell must fit the dynamic viewport');

  await page.waitForFunction(()=>document.querySelector('#status')?.classList.contains('ready'),null,{timeout:60000});
  const frameIsLoaded=await page.evaluate(()=>{
    const frame=document.getElementById('game').contentWindow;
    window.__consoleAudit=[];
    const original=frame.__evilWizardInput;
    if(typeof original!=='function')return false;
    frame.__evilWizardInput=function(message){window.__consoleAudit.push(JSON.parse(message));return original(message)};
    return Boolean(frame.document.querySelector('canvas'));
  });
  assert(frameIsLoaded,'Godot canvas and callable input bridge must run in iframe');

  await page.locator('#champion-choice').selectOption('warrior');
  const titleImage=await page.locator('#game').screenshot();
  await page.locator('#start-champion').click();
  await page.waitForFunction(()=>window.__consoleAudit.some(m=>m.kind==='start'&&m.hero_class==='warrior'));
  assert.match(await page.locator('#status').textContent(),/INTERACT/,'Start must tell the player how to advance the opening');
  assert.equal(await page.locator('button[data-action="interact"]').evaluate(el=>el.classList.contains('tutorial-pulse')),true,'Interact must be visibly highlighted during opening');
  await page.waitForTimeout(450);
  const prologueImage=await page.locator('#game').screenshot();
  assert(!titleImage.equals(prologueImage),'Starting champion must show opening prologue');
  for(let beat=0;beat<3;beat++){
    await page.locator('button[data-action="interact"]').click({force:true});
    await page.waitForTimeout(220);
  }
  const gameImage=await page.locator('#game').screenshot();
  assert(!prologueImage.equals(gameImage),'Mobile Interact must advance prologue to game screen');

  await page.locator('button[data-action="attack"]').click();
  await page.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='attack'&&m.pressed===true));
  await page.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='attack'&&m.pressed===false));

  const joy=await page.locator('#joystick').boundingBox(),attack=await page.locator('button[data-action="attack"]').boundingBox();
  const c=b=>({x:Math.round(b.x+b.width/2),y:Math.round(b.y+b.height/2)}),j=c(joy),a=c(attack);
  const first={x:j.x+Math.round(joy.width*.25),y:j.y,id:1},second={x:a.x,y:a.y,id:2};
  const cdps=await mobileContext.newCDPSession(page);
  await cdps.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[first]});
  await cdps.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[first,second]});
  await page.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='move_right'&&m.pressed===true)&&window.__consoleAudit.some(m=>m.action==='attack'&&m.pressed===true));
  await cdps.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[first]});
  await cdps.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await page.waitForFunction(()=>window.__consoleAudit.some(m=>m.action==='move_right'&&m.pressed===false));
  const scale=await page.evaluate(()=>window.visualViewport?.scale ?? 1);
  assert.equal(scale,1,'Multi-touch gameplay must not zoom the browser page');
  await page.screenshot({path:'build/handheld-console-preview.png'});
  assert.equal(errors.length,0,`Mobile browser JS errors: ${errors.join('; ')}`);
  await mobileContext.close();

  // Portrait handhelds must stop at an orientation gate instead of exposing
  // undersized gameplay controls. Rotating to landscape reveals the console.
  const portraitContext = await browser.newContext({
    viewport:{width:393,height:852},isMobile:true,hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1'
  });
  const portraitPage = await portraitContext.newPage();
  const portraitErrors=[];
  portraitPage.on('pageerror',error=>portraitErrors.push(String(error)));
  await portraitPage.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  await portraitPage.waitForURL(/\/console\.html$/);
  assert.equal(await portraitPage.locator('.orientation-gate').isVisible(),true,'Portrait handheld must ask the player to rotate sideways');
  assert.match(await portraitPage.locator('.orientation-gate').textContent(),/Turn your device sideways/,'Orientation gate must clearly explain landscape play');
  assert.equal(await portraitPage.locator('.console').isVisible(),false,'Handheld console must stay hidden in portrait');
  await portraitPage.setViewportSize({width:852,height:393});
  await portraitPage.waitForFunction(()=>getComputedStyle(document.querySelector('.orientation-gate')).display==='none');
  assert.equal(await portraitPage.locator('#joystick').isVisible(),true,'Rotating to landscape must reveal movement controls');
  assert.equal(await portraitPage.locator('button[data-action="attack"]').isVisible(),true,'Rotating to landscape must reveal action controls');
  assert.equal(portraitErrors.length,0,`Portrait browser JS errors: ${portraitErrors.join('; ')}`);
  await portraitContext.close();

  // A large touch-capable PC must stay in desktop mode; touch alone must not
  // create the handheld console on a laptop/large display.
  const largeTouchContext = await browser.newContext({
    viewport:{width:1920,height:1080},hasTouch:true,deviceScaleFactor:1,
    userAgent:'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/140 Safari/537.36'
  });
  const largeTouchPage = await largeTouchContext.newPage();
  await largeTouchPage.goto('http://127.0.0.1:8765/play.html',{waitUntil:'domcontentloaded'});
  assert.match(largeTouchPage.url(),/\/play\.html$/,'Large touch PC must remain on desktop launcher');
  assert.equal(await largeTouchPage.locator('#desktop-shell').isVisible(),true,'Large touch PC must use desktop game layout');
  assert.equal(await largeTouchPage.locator('.console').count(),0,'Large touch PC must never generate handheld console');
  await largeTouchContext.close();

  const desktopContext = await browser.newContext({viewport:{width:1365,height:768},hasTouch:false,deviceScaleFactor:1});
  const desktop = await desktopContext.newPage();
  const desktopErrors=[];
  desktop.on('pageerror',error=>desktopErrors.push(String(error)));
  const response=await desktop.goto('http://127.0.0.1:8765/play.html?mode=desktop',{waitUntil:'domcontentloaded'});
  assert.equal(response.status(),200,'Adaptive launcher must be served');
  assert.equal(await desktop.locator('#game').getAttribute('src'),'./index.html','Desktop launcher must use keyboard/mouse Web game');
  assert.equal(await desktop.locator('#enter').isVisible(),true,'Desktop must expose a keyboard-accessible fullscreen start surface');
  const fit=await desktop.evaluate(()=>{
    const frame=document.getElementById('game').getBoundingClientRect();
    const style=getComputedStyle(document.getElementById('game'));
    return {x:frame.x,y:frame.y,w:frame.width,h:frame.height,iw:innerWidth,ih:innerHeight,border:style.borderWidth,overflowX:document.documentElement.scrollWidth-innerWidth,overflowY:document.documentElement.scrollHeight-innerHeight};
  });
  assert.equal(fit.x,0); assert.equal(fit.y,0);
  assert.equal(Math.round(fit.w),fit.iw,'Desktop game must fill screen width');
  assert.equal(Math.round(fit.h),fit.ih,'Desktop game must fill screen height');
  assert.equal(fit.border,'0px','Desktop game must have no iframe border');
  assert.equal(fit.overflowX,0); assert.equal(fit.overflowY,0);
  await desktop.keyboard.press('Enter');
  await desktop.waitForFunction(()=>document.getElementById('enter').hidden===true);
  assert.equal(desktopErrors.length,0,`Desktop browser JS errors: ${desktopErrors.join('; ')}`);
  await desktopContext.close();

  console.log('Browser passed: handheld landscape console, portrait rotate gate, pre-game controls help, large-touch desktop split, keyboard/mouse desktop launch, and borderless viewport.');
} finally {
  await browser.close();
}
