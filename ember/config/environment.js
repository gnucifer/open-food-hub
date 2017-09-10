/* eslint-env node */
'use strict';

module.exports = function(environment) {
  let ENV = {
    modulePrefix: 'ofh',
    environment,
    rootURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      },
      EXTEND_PROTOTYPES: {
        // Prevent Ember Data from overriding Date.parse.
        Date: false
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    }
  };

  // TODO: better name OFH-API:
  ENV['api'] = {
    namespace: 'api/v1',
	  host: 'http://localhost:4000',
    tokenEndpoint: 'http://localhost:4000/auth/authorize',
    tokenRefreshLeeway: 850,//300, // In seconds
  };

  // Ember-simple-auth configuration
  ENV['simple-auth'] = {
    store: 'simple-auth-session-store:local-storage',
    authorizer: 'authorizer:ofh',
    // Authenticator???
    authorizer: 'authorizer:ofh',
    crossOriginWhitelist: ['http://localhost:4000/'],
    routeAfterAuthentication: '/protected'
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {

  }

  return ENV;
};
