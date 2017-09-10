import AdaptiveStore from 'ember-simple-auth/session-stores/local-storage';

export default AdaptiveStore.extend({
  // TODO: What is the default cookie name
  // TODO: From env config?
  cookieName: 'ofh-session',
});
