"use client";

import { config } from "./package.json";

import { ApplicationInsights } from "@microsoft/applicationinsights-web";

const y = new ApplicationInsights({
  config: {
    connectionString: config.applicationInsights_connectionString,
    autoTrackPageVisitTime: true
  }
});

export default y.loadAppInsights();
