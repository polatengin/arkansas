"use client";

import appInsights from '@/ai';

import { useEffect } from 'react';

export default function Doctors() {
  useEffect(() => {
    appInsights.trackPageView({ name: "doctors_pageView" });
    appInsights.trackEvent({ name: "doctors_event" });
    appInsights.trackTrace({ message: "doctors_trace" });
    appInsights.trackException({ exception: new Error("doctors_exception") });
    appInsights.trackMetric({ name: "doctors_metric", average: 1 });
    appInsights.flush();
    console.log(appInsights);
    console.log("doctors");
  });

  return (
    <main>
      <h1>Doctors</h1>
    </main>
  )
}
