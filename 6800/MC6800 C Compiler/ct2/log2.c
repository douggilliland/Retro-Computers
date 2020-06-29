main() {
  int a,b,c,d,e,f;
  int g,h,i;

  if (a||(b&&(c||d)&&(e||f)&&g)&&h) a=4;
  if (a&&(b||(c&&d)||(e&&f)||g)||h) a=5;
  if (a&&b&&c&&d||e&&f&&g&&h) a=6;
  if (a||b||c||d||(e&&f&&g&&h)) a=7;
  if ((a||b&&c)||(c&&d||e)&&(f||g||h)) a=8;
  if (a||(b&&(c||(d&&f)||g)&&h)||i) a=9;
  if (a&&(b||(c&&(d||f)&&g)||h)&&i) a=10;
}
