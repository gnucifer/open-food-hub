import Ember from 'ember';
import { inject } from '@ember/service'; // TODO: inject as service?
import { isForbiddenError, isUnauthorizedError } from 'ember-ajax/errors';
import Base from 'ember-simple-auth/authenticators/base';
import config from '../config/environment';

export default Base.extend({
  // TODO: Can't remember, but should be placed in constructor??
  tokenEndpoint: config.api.tokenEndpoint,
  refreshLeeway: config.api.tokenRefreshLeeway,
  ajax: inject(),

  restore(data) {
    return new Ember.RSVP.Promise((resolve, reject) => {
      if (
          data['expires_at'] > this.getCurrentTime() &&
          !Ember.isEmpty(data['access_token']) &&
          !Ember.isEmpty(data['refresh_token'])
      ) {
        this.scheduleAccessTokenRefresh(data['expires_at'], data['refresh_token']);
        resolve(data);
      } else {
        this.invalidateSession().then(function() {
          reject(new Error('invalid data received when trying to restore session'));
        });
      }
    });
  },

  authenticate(credentials) {
    // TODO: Could template this code and break out in function, but hardly worth it
    return new Ember.RSVP.Promise((resolve, reject) => {
      this.get('ajax').post(this.tokenEndpoint + '?grant_type=password', {
        dataType: 'json',
        data: {
          'username_or_email': credentials.identification,
          'password': credentials.password
        }
      }).then((response) => {
        try {
          let data = this.handleAuthResponse(response);
          this.trigger('sessionDataCreated', data);
          resolve(data);
        } catch (error) {
          reject(error);
        }
      }, (error) => {
        //TODO: This should probably be handled differently,
        // unser notification when login fail etc, not sure what
        // happens if just rejects here
        reject(error);
      });
    });
  },

  invalidate() {
    return Ember.RSVP.resolve();
  },

  /**
    Returns the current time as a timestamp in seconds
    @method getCurrentTime
    @return {Integer} timestamp
  */
  getCurrentTime() {
    return Math.floor((new Date()).getTime() / 1000);
  },

  getTokenData(token) {
    let payload = token.split('.')[1];
    // @TODO: find out reason behind this kludge:
    let data = decodeURIComponent(window.escape(window.atob(payload)));
    return JSON.parse(data);
  },

  cancelScheduledAccessTokenRefresh() {
    if (this._refreshTokenTimeout) {
      Ember.run.cancel(this._refreshTokenTimeout);
      delete this._refreshTokenTimeout;
    }
  },

  scheduleAccessTokenRefresh(expires_at, refresh_token) {
    let wait = (expires_at - this.getCurrentTime() - this.refreshLeeway) * 1000;
    if(wait < 0) {
      // This case should be pretty rare/impossible
      wait = 0;
    }
    this.cancelScheduledAccessTokenRefresh();
    this._refreshTokenTimeout = Ember.run.later(this, this.refreshAccessToken, refresh_token, wait);
  },

  refreshAccessToken(refresh_token) {
    return new Ember.RSVP.Promise((resolve, reject) => {
      this.get('ajax').post(this.tokenEndpoint + '?grant_type=refresh_token', {
        dataType: 'json',
        data: {
          'refresh_token': refresh_token
        }
      }).then((response) => {
        try {
          let data = this.handleAuthResponse(response);
          resolve(data);
        } catch (error) {
          reject(error);
        }
      }, (error) => {
        Ember.Logger.warn(
            'Access token could not be refreshed - ' +
            `server responded with ${error.payload}.`
            );
        this.handleTokenRefreshFail(error);
        reject(error);
      });
    });
  },

  handleAuthResponse(response_data) {
    // Validate response data, really not much sense doing this
    // except for debugging purposes
    if (Ember.isEmpty(response_data['access_token'])) {
      throw new Error('missing token');
    }
    if (Ember.isEmpty(response_data['refresh_token'])) {
      throw new Error('missing refresh token');
    }

    let token_data = this.getTokenData(response_data['access_token']);

    let expires_at = token_data['exp']; // TODO: consistent naming
    if (Ember.isEmpty(expires_at)) {
      throw new Error('missing token expiry date');
    }
    // Stash access token expiry date for convenient access
    // TODO: BIG FAT WARNING, RIGHT NOW WILL OVERWRITE RERESH TOKEN EXPIRY DATE WICH I WILL REMOVE
    // SINCE REFRESH TOKENS SHALL NOT HAVE AN EXPIRY DATE
    response_data['expires_at']	= expires_at;
    this.scheduleAccessTokenRefresh(expires_at, response_data['refresh_token']);
    return response_data;
  },

  /**
    Handles token refresh fail status. If the server response to a token refresh has a
    status of 401 or 403 then the token in the session will be invalidated and
    the sessionInvalidated provided by ember-simple-auth will be triggered.
    @method handleTokenRefreshFail
    */
  handleTokenRefreshFail(error) {
    if (isUnauthorizedError(error) || isForbiddenError(error)) {
      return this.invalidateSession();
    }
  },

  invalidateSession() {
    return this.invalidate().then(() => {
      this.trigger('sessionDataInvalidated');
    });
  }

});
