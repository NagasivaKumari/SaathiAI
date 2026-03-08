import fs from 'fs';
import path from 'path';

const schemesJsonPath = path.resolve('d:/SaathiAI/Schemes/govt_schemes.json');

export function readSchemesJson() {
  try {
    const data = fs.readFileSync(schemesJsonPath, 'utf-8');
    const json = JSON.parse(data);
    return json.schemes || [];
  } catch (err) {
    console.error('Error reading schemes JSON:', err);
    return [];
  }
}
