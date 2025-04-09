import { NextRequest } from 'next/server';

const MSI_ENDPOINT = 'http://169.254.169.254/metadata/identity/oauth2/token';
const API_RESOURCE = 'https://api.loganalytics.io';
const WORKSPACE_ID = process.env.APPLICATION_INSIGHTS_ID!;

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const kql = body.kql || 'requests | take 10';

    const tokenRes = await fetch(
      `${MSI_ENDPOINT}?api-version=2018-02-01&resource=${encodeURIComponent(API_RESOURCE)}`,
      {
        method: 'GET',
        headers: {
          Metadata: 'true',
        },
      }
    );

    if (!tokenRes.ok) {
      const error = await tokenRes.text();
      return new Response(JSON.stringify({ error: 'Failed to get MSI token', detail: error }), { status: 500 });
    }

    const { access_token } = await tokenRes.json();

    const queryRes = await fetch(`https://api.loganalytics.io/v1/workspaces/${WORKSPACE_ID}/query`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query: kql }),
    });

    if (!queryRes.ok) {
      const error = await queryRes.text();
      return new Response(JSON.stringify({ error: 'Query failed', detail: error }), { status: 500 });
    }

    const data = await queryRes.json();

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err: any) {
    return new Response(
      JSON.stringify({
        error: 'Unhandled exception',
        detail: err?.message || 'Unknown error',
      }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
};
