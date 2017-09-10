import Ember from 'ember';
import Base from 'ember-simple-auth/authorizers/base';
export default Base.extend({
  session: Ember.inject.service('session'),
  authorize: function(data, block = () => {}) {
		if (this.get('session.isAuthenticated') && !Ember.isEmpty(data['access_token'])) {
      block('Authorization', 'Bearer ' + data['access_token']);
		}
	}
});
