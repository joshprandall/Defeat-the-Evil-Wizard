(() => {
  'use strict';
  const champions = [
    ['warrior','Warrior'],['mage','Mage'],['rogue','Rogue'],['paladin','Paladin'],
    ['archer','Archer'],['barbarian','Barbarian'],['fighter','Fighter'],['monk','Monk'],
    ['ranger','Ranger'],['cleric','Cleric'],['bard','Bard'],['druid','Druid'],
    ['sorcerer','Sorcerer'],['warlock','Warlock'],['wizard','Wizard']
  ];
  const keyboard = 'Keyboard / mouse: A / D or ← / → move · S / Q crouch · W / E jump · Space / J / left click attack · K / right click heavy · Shift dash · F interact · L / I abilities · U ultimate · Esc pause.';
  const xbox = 'Xbox / standard gamepad: Left stick or D-pad moves · down crouches · right stick aims · A jump · B dash · X attack · Y heavy · LB / RB abilities · LT interact · RT ultimate · Menu/Start pause.';
  const playstation = 'PlayStation controller: Left stick or D-pad moves · down crouches · right stick aims · Cross jump · Circle dash · Square attack · Triangle heavy · L1 / R1 abilities · L2 interact · R2 ultimate · Options pause.';
  const touch = 'Phone / Tablet: Left floating stick moves and crouches. Floating buttons at the right edge control attack, jump, heavy attack, dash, abilities, ultimate and interact. Multiple touches work at once. Rotate the phone or tablet to landscape after pressing Start.';
  window.EvilWizardSetup = {champions, guides:{keyboard,xbox,playstation,touch}};
})();