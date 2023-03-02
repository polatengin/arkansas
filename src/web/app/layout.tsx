"use client";
import './globals.css'

import appInsights from '@/ai';

import { useEffect } from 'react';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  useEffect(() => {
    appInsights.trackPageView({ name: "pageView" });
    appInsights.trackEvent({ name: "event" });
    appInsights.trackTrace({ message: "trace" });
    appInsights.trackException({ exception: new Error("exception") });
    appInsights.trackMetric({ name: "metric", average: 1 });
    appInsights.flush();
    console.log("appInsights");
  });

  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
