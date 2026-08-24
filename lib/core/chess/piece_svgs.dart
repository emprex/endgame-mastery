const String kingSvg = '''
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' fill='none' stroke='currentColor' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'>
  <path d='M50 12v16'/>
  <path d='M42 20h16'/>
  <path d='M35 42h30'/>
  <path d='M40 28c0 6-8 11-8 21 0 14 9 23 18 23s18-9 18-23c0-10-8-15-8-21'/>
  <path d='M33 72h34'/>
  <path d='M28 80h44'/>
  <path d='M24 88h52'/>
</svg>
''';

const String queenSvg = '''
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' fill='none' stroke='currentColor' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'>
  <circle cx='24' cy='22' r='5'/>
  <circle cx='40' cy='16' r='5'/>
  <circle cx='60' cy='16' r='5'/>
  <circle cx='76' cy='22' r='5'/>
  <path d='M24 27l8 32h36l8-32'/>
  <path d='M32 59h36'/>
  <path d='M28 70h44'/>
  <path d='M24 80h52'/>
  <path d='M20 88h60'/>
</svg>
''';

const String rookSvg = '''
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' fill='none' stroke='currentColor' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'>
  <path d='M28 18h10v12h8V18h8v12h8V18h10v18H28z'/>
  <path d='M34 36v22'/>
  <path d='M66 36v22'/>
  <path d='M32 58h36'/>
  <path d='M28 70h44'/>
  <path d='M24 80h52'/>
  <path d='M20 88h60'/>
</svg>
''';

const String bishopSvg = '''
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' fill='none' stroke='currentColor' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'>
  <circle cx='50' cy='20' r='7'/>
  <path d='M58 28c0 8-6 11-6 18 0 5 4 8 8 12 5 5 8 10 8 16 0 7-8 12-18 12s-18-5-18-12c0-6 3-11 8-16 4-4 8-7 8-12 0-7-6-10-6-18'/>
  <path d='M44 50l12-12'/>
  <path d='M32 70h36'/>
  <path d='M28 80h44'/>
  <path d='M24 88h52'/>
</svg>
''';

const String knightSvg = '''
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' fill='none' stroke='currentColor' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'>
  <path d='M66 24c-10 0-18 4-24 12l-10 14c-5 7-6 13-6 18 0 10 8 18 20 18h24c10 0 16-5 16-12 0-7-5-12-10-17-4-4-6-7-6-11 0-5 2-8 4-12 1-3 2-5 2-10 0-4-4-8-10-8z'/>
  <path d='M44 38c6 0 10 2 14 6'/>
  <circle cx='54' cy='34' r='2.5' fill='currentColor' stroke='none'/>
  <path d='M34 70h32'/>
  <path d='M30 80h40'/>
  <path d='M24 88h52'/>
</svg>
''';

const String pawnSvg = '''
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100' fill='none' stroke='currentColor' stroke-width='6' stroke-linecap='round' stroke-linejoin='round'>
  <circle cx='50' cy='24' r='10'/>
  <path d='M38 48c0-9 6-16 12-16s12 7 12 16c0 5-2 8-5 12h9c4 3 6 7 6 12 0 8-8 12-22 12s-22-4-22-12c0-5 2-9 6-12h9c-3-4-5-7-5-12z'/>
  <path d='M30 88h40'/>
</svg>
''';

String pieceSvgByKey(String key) {
  switch (key) {
    case 'king':
      return kingSvg;
    case 'queen':
      return queenSvg;
    case 'rook':
      return rookSvg;
    case 'bishop':
      return bishopSvg;
    case 'knight':
      return knightSvg;
    case 'pawn':
      return pawnSvg;
  }

  return pawnSvg;
}
