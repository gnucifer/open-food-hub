import Route from '@ember/routing/route';
import UnauthenticatedRouteMixin from 'ember-simple-auth/mixins/unauthenticated-route-mixin';

// TODO: find out implications of this? Check out mixin
export default Route.extend(UnauthenticatedRouteMixin, {
});
