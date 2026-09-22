import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';

const { chromium } = await import(pathToFileURL(`${process.env.PLAYWRIGHT_MODULE}/index.mjs`).href);
const browser = await chromium.launch({
  headless: true,
  args: ['--no-sandbox', '--enable-webgl', '--use-gl=angle', '--use-angle=swiftshader'],
});
try {
  const context = await browser.newContext({ viewport: { width: 844, height: 390 }, isMobile: true, hasTouch: true, deviceScaleFactor: 1 });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', error => errors.push(String(error)));
  const response = await page.goto('http://127.0.0.1:8765/console.html', { waitUntil: 'domcontentloaded' });
  assert.equal(response.status(), 200, 'Handheld console must be served');
  assert.equal(await page.locator('#game').getAttribute('src'), './index.html');
  assert.equal(await page.locator('button[data-action]').count(), 12, 'Movement dpad and action buttons must be visible');
  assert.equal(await page.locator('#joystick').isVisible(), true, 'Joystick must be visible in landscape');
  assert.equal(await page.locator('#champion-choice option').count(), 15, 'All champions selectable without tiny game menu');
  assert.equal(await page.locator('#start-champion').isVisible(), true, 'Large mobile start button must be visible');
  const rails = await page.evaluate(() => {
    const game = document.getElementById('game').getBoundingClientRect();
    const left = document.querySelector('.rail.left').getBoundingClientRect();
    const right = document.querySelector('.rail.right').getBoundingClientRect();
    return { game: { x: game.x, right: game.right, width: game.width }, leftRight: left.right, rightX: right.x };
  });
  assert(rails.game.width > 150 && rails.leftRight <= rails.game.x && rails.game.right <= rails.rightX,
    'The game must be between two independent controller rails');

  await page.waitForFunction(() => document.querySelector('#status')?.classList.contains('ready'), null, { timeout: 60_000 });
  const frameIsLoaded = await page.evaluate(() => {
    const frame = document.getElementById('game').contentWindow;
    window.__consoleAudit = [];
    const original = frame.__evilWizardInput;
    if (typeof original !== 'function') return false;
    frame.__evilWizardInput = function (message) {
      window.__consoleAudit.push(JSON.parse(message));
      return original(message);
    };
    return Boolean(frame.document.querySelector('canvas'));
  });
  assert(frameIsLoaded, 'Godot canvas and callable input bridge must be running in iframe');

  await page.locator('#champion-choice').selectOption('warrior');
  const titleImage = await page.locator('#game').screenshot();
  await page.locator('#start-champion').click();
  await page.waitForFunction(() => window.__consoleAudit.some(m => m.kind === 'start' && m.hero_class === 'warrior'));
  await page.waitForTimeout(900);
  const playImage = await page.locator('#game').screenshot();
  assert(!titleImage.equals(playImage), 'Starting champion must change the game screen');

  await page.locator('button[data-action="attack"]').click();
  await page.waitForFunction(() => window.__consoleAudit.some(m => m.action === 'attack' && m.pressed === true));
  await page.waitForFunction(() => window.__consoleAudit.some(m => m.action === 'attack' && m.pressed === false));

  const joy = await page.locator('#joystick').boundingBox();
  const attack = await page.locator('button[data-action="attack"]').boundingBox();
  const c = box => ({ x: Math.round(box.x + box.width / 2), y: Math.round(box.y + box.height / 2) });
  const j = c(joy), a = c(attack);
  const first = { x: j.x + Math.round(joy.width * .25), y: j.y, id: 1 };
  const second = { x: a.x, y: a.y, id: 2 };
  const cdps = await context.newCDPSession(page);
  await cdps.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [first] });
  await cdps.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [first, second] });
  await page.waitForFunction(() => window.__consoleAudit.some(m => m.action === 'move_right' && m.pressed === true)
    && window.__consoleAudit.some(m => m.action === 'attack' && m.pressed === true));
  await cdps.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [first] });
  await cdps.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await page.waitForFunction(() => window.__consoleAudit.some(m => m.action === 'move_right' && m.pressed === false));
  await page.screenshot({ path: 'build/handheld-console-preview.png' });
  assert.equal(errors.length, 0, `Browser JavaScript errors: ${errors.join('; ')}`);
  console.log('Real browser: landscape shell, champion start, Godot canvas and simultaneous joystick/attack passed.');
} finally {
  await browser.close();
}
