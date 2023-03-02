"use client";

import { config } from "./package.json";

import { ApplicationInsights } from "@microsoft/applicationinsights-web";

const ai = new ApplicationInsights({
  config: {
    connectionString: config.applicationInsights_connectionString,
    autoTrackPageVisitTime: true
  }
});

export default ai.loadAppInsights();
