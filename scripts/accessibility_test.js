/* accessibility_test.js
 * Runs axe-core accessibility checks via puppeteer + axe-puppeteer
 * Writes per-page JSON reports to the output directory.
 * Usage: node scripts/accessibility_test.js
 */
import http from 'http';
import fs from 'fs';
import path from 'path';
import url from 'url';
import puppeteer from 'puppeteer';
import { AxePuppeteer } from 'axe-puppeteer';

const PUBLIC_DIR = path.resolve(process.cwd(), 'public');
const PORT = process.env.VISUAL_TEST_PORT || 8080;
const OUTPUT_DIR = process.env.ACCESSIBILITY_OUTPUT_DIR || path.resolve(process.cwd(), '.accessibility-output');

async function startServer() {
  const server = http.createServer((req, res) => {
    try {
      const parsed = url.parse(req.url);
      let pathname = decodeURIComponent(parsed.pathname);
      if (pathname === '/') pathname = '/index.html';
      const filePath = path.join(PUBLIC_DIR, pathname);
      if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
        const stream = fs.createReadStream(filePath);
        const ext = path.extname(filePath).toLowerCase();
        const mime = {
          '.html': 'text/html',
          '.js': 'text/javascript',
          '.css': 'text/css',
          '.png': 'image/png',
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.svg': 'image/svg+xml',
          '.json': 'application/json',
        }[ext] || 'application/octet-stream';
        res.writeHead(200, { 'Content-Type': mime });
        stream.pipe(res);
      } else {
        res.writeHead(404);
        res.end('Not found');
      }
    } catch (err) {
      res.writeHead(500);
      res.end('Server error');
    }
  });

  return new Promise((resolve) => {
    server.listen(PORT, () => resolve(server));
  });
}

async function runScan() {
  if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  const server = await startServer();
  console.log('Serving public/ on http://localhost:' + PORT);

  const browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  try {
    const page = await browser.newPage();
    const pages = ['/login.html', '/dashboard.html', '/advantages.html'];
    const summary = {};

    for (const p of pages) {
      const urlToVisit = `http://localhost:${PORT}${p}`;
      console.log('Scanning', urlToVisit);
      await page.goto(urlToVisit, { waitUntil: 'networkidle2', timeout: 30000 });
      await new Promise((r) => setTimeout(r, 500));

      const results = await new AxePuppeteer(page).analyze();
      const fileSafe = p.replace(/\W+/g, '_').replace(/^_+|_+$/g, '');
      const outFile = path.join(OUTPUT_DIR, `${fileSafe}.axe.json`);
      fs.writeFileSync(outFile, JSON.stringify(results, null, 2), 'utf-8');

      summary[p] = {
        violations: results.violations.length,
        incomplete: results.incomplete.length,
        passes: results.passes.length,
        inapplicable: results.inapplicable.length,
        output: outFile,
      };

      console.log(`Page ${p}: ${results.violations.length} violations, report -> ${outFile}`);
    }

    const summaryFile = path.join(OUTPUT_DIR, 'summary.json');
    fs.writeFileSync(summaryFile, JSON.stringify(summary, null, 2), 'utf-8');
    console.log('Accessibility scan summary:', summaryFile);

    return { summaryFile, summary };
  } finally {
    await browser.close();
    server.close();
  }
}

runScan().catch((err) => {
  console.error('Accessibility scan failed:', err);
  process.exit(1);
});
