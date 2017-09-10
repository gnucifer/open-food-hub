import { inject as service } from '@ember/service';
import Route from '@ember/routing/route';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';

export default Route.extend(ApplicationRouteMixin, {
  sessionAccount: service('session-account'),

  beforeModel() {
		//TODO: how the fuck is this not run twice?
    return this._loadCurrentUser();
  },

  sessionAuthenticated() {
    this._super(...arguments);
    this._loadCurrentUser();
  },

	actions: {
		invalidateSession: function() {
			this.get('session').invalidate();
		}
	},

  _loadCurrentUser() {
    return this
      .get('sessionAccount')
      .loadCurrentUser()
      .catch(
        // TODO: where does session come from?
        () => this.get('session').invalidate() //Invoke action instead?
      );
  },


});
