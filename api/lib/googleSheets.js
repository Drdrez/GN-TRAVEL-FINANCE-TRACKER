import { google } from 'googleapis';

// Initialize Auth
const auth = new google.auth.GoogleAuth({
  credentials: {
    client_email: process.env.GOOGLE_CLIENT_EMAIL,
    // Vercel env vars often escape newlines, so we fix them here
    private_key: (process.env.GOOGLE_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
  },
  scopes: ['https://www.googleapis.com/auth/spreadsheets'],
});

const sheets = google.sheets({ version: 'v4', auth });
const SPREADSHEET_ID = process.env.GOOGLE_SHEET_ID;

/**
 * Overwrites a specific sheet (tab) with new data
 * @param {string} tabName - The name of the tab (e.g., "Income", "Expenses")
 * @param {Array<Array<string>>} values - 2D array of data including headers
 */
export async function pushToSheet(tabName, values) {
  try {
    // 1. Clear the existing content in the tab
    await sheets.spreadsheets.values.clear({
      spreadsheetId: SPREADSHEET_ID,
      range: `${tabName}!A:Z`, // Clears columns A to Z
    });

    // 2. Write the new data
    await sheets.spreadsheets.values.update({
      spreadsheetId: SPREADSHEET_ID,
      range: `${tabName}!A1`,
      valueInputOption: 'USER_ENTERED',
      requestBody: {
        values: values,
      },
    });
    
    console.log(`Synced ${tabName} successfully.`);
  } catch (error) {
    console.error(`Error syncing ${tabName}:`, error);
    throw error;
  }
}