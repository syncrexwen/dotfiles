/**
{
  "api": 1,
  "name": "SQL to params",
  "description": "lines -> 'a' 'b' 'c'",
  "author": "kcwen",
  "icon": "table",
  "tags": "sql,params,cli"
}
**/
function main(state) {
  const items = state.text.split("\n").map(s => s.trim()).filter(Boolean);
  state.text = items.map(s => "'" + s.replace(/'/g, "''") + "'").join(" ");
}

