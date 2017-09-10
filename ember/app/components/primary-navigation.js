import Ember from 'ember';
import { inject as service } from '@ember/service';

export default Ember.Component.extend({
  session: service('session'),
  sessionAccount: service('session-account'),

	actions: {
		login() {
			// Closure actions are not yet available in Ember 1.12
			// eslint-disable-next-line ember/closure-actions
			// TODO: Fix
			this.sendAction('onLogin');
		},

		logout() {
			this.get('session').invalidate();
		}
	}
});
