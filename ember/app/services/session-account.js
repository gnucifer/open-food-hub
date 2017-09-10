import RSVP from 'rsvp';
import Service, { inject as service } from '@ember/service';
import { isEmpty } from '@ember/utils';

export default Service.extend({
	session: service(),
	store: service(), //TODO: do we need to do this to use ember data?

	// TODO: Think about this, do we need user?
	loadCurrentUser() {
		// @TODO: Replace Ember.rsvp.promise with this in other parts of code
		return new RSVP.Promise((resolve, reject) => {
			const userId = this.get('session.data.authenticated.user_id');
			if (!isEmpty(userId)) {
				this.get('store').find('user', userId).then((user) => {
					this.set('user', user);
					resolve();
				}, reject);
			} else {
				resolve();
			}
		});
	}
});
