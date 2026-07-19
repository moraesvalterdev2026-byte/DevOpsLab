import { build } from 'esbuild';
import fs from 'fs';
import path from 'path';

const PUBLIC = path.resolve(process.cwd(), 'public');
const OUTDIR = path.resolve(PUBLIC, 'dist');
if (!fs.existsSync(OUTDIR)) fs.mkdirSync(OUTDIR, { recursive: true });

(async function(){
  try {
    // Bundle main.js and page entrypoints
    await build({
      entryPoints: [
        path.join(PUBLIC, 'js', 'main.js')
      ],
      bundle: true,
      minify: true,
      sourcemap: false,
      platform: 'browser',
      target: ['es2020'],
      outfile: path.join(OUTDIR, 'bundle.js')
    });

    // Copy static assets (css)
    const cssSrc = path.join(PUBLIC, 'css', 'main.css');
    const cssDest = path.join(OUTDIR, 'main.css');
    if (fs.existsSync(cssSrc)) fs.copyFileSync(cssSrc, cssDest);

    console.log('Frontend build completed. Output in', OUTDIR);
    process.exit(0);
  } catch (err) {
    console.error('Build failed:', err);
    process.exit(1);
  }
})();
