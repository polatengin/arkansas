"use client";

import { useState } from "react";

export default function Home() {
  const [query, setQuery] = useState('requests | take 5');
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const runQuery = async () => {
    setLoading(true);
    setResult(null);
    try {
      const res = await fetch('/api/queryLogs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ kql: query }),
      });
      const data = await res.json();
      setResult(data);
    } catch (err) {
      setResult({ error: 'Failed to fetch' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-4">
      <h1 className="text-xl font-bold mb-2">App Insights Log Query</h1>
      <textarea
        className="w-full border p-2 mb-2"
        rows={4}
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      <button
        onClick={runQuery}
        className="bg-blue-600 text-white px-4 py-2 rounded"
      >
        Run Query
      </button>
      <div className="mt-4">
        {loading && <p>Loading...</p>}
        {result && (
          <pre className="bg-gray-100 p-2 text-sm overflow-x-auto">
            {JSON.stringify(result, null, 2)}
          </pre>
        )}
      </div>
    </div>
  );
}
