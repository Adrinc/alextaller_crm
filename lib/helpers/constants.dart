//////// DEV CBLUNA ////////
const String supabaseUrl = 'https://cbl-supabase.virtalus.cbluna-dev.com';
const String anonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzE1MjM4MDAwLAogICJleHAiOiAxODczMDA0NDAwCn0.qKqYn2vjtHqKqyt1FAghuIjvNsyr9b1ElpVfvJg6zJ4';
const String storageBooksCover =
    'https://cbl-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/lectores_urb/books_cover/';
const String storageBooks = 'lectores_urb/books';

const redirectUrl = '$supabaseUrl/change-pass/change-password/token';

const String apiGatewayUrl = 'https://cbl.virtalus.cbluna-dev.com/uapi/lu/api';
const String n8nUrl = 'https://u-n8n.virtalus.cbluna-dev.com/webhook';
const bearerApiGateway = "Basic YWlyZmxvdzpjYiF1bmEyMDIz";

const int organizationId = 10;
const String lectoresUrl = 'https://lectoresurbanos.com/';

const themeId = String.fromEnvironment('themeId', defaultValue: '2');
const int mobileSize = 800;
