import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class AdminBuildnetRoute extends DiscourseRoute {
  model() {
    return ajax("/buildnet/logs");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.logs = model.logs;
  }
} 