const PRODUCTION = true;
const API_URL = 'api.holysheet.net';
const PROTOCOL = PRODUCTION ? 'https' : 'http';
const WEBSOCKET_PROTOCOL = PRODUCTION ? 'wss' : 'ws';
const BASE_URL = '$PROTOCOL://$API_URL';
