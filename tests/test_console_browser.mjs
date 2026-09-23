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
  await page.waitForTimeout(450);
  const prologueImage=await page.locator('#game').screenshot();
  assert(!titleImage.equals(prologueImage),'Starting champion must show opening prologue');
  for(let beat=0;beat<3;beat++){
    await page.locator('button[data-action="jump"]').click();
    await page.waitForTimeout(200);
  }
  const gameImage=await page.locator('#game').screenshot();
  assert(!prologueImage.equals(gameImage),'Mobile Jump must advance prologue to game screen');

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
  await page.screenshot({path:'build/handheld-console-preview.png'});
  assert.equal(errors.length,0,`Mobile browser JS errors: ${errors.join('; ')}`);
  await mobileContext.close();

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

  console.log('Browser passed: adaptive mobile console, simultaneous touch, desktop keyboard launch, and borderless dynamic viewport.');
} finally {
  await browser.close();
}
