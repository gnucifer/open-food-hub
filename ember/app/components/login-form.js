import { inject as service } from '@ember/service';
import Component from '@ember/component';
//import config from '../config/environment';

export default Component.extend({
  session: service('session'), // service() ?
  actions: {
    // TODO: This function needs to take params, "method" etc? for password/github/facebook etc
    authenticate() {
      let credentials = this.getProperties('identification', 'password');
      // TODO: change to this?:
      // let { identification, password } = this.getProperties('identification', 'password');
      // this.get('session').authenticate('authenticator:ofh', identification, password).catch((message) => {
      this.get('session').authenticate('authenticator:ofh', credentials).catch((reason) => {
        this.set('errorMessage', reason.error);
      });
    }
  }
});
