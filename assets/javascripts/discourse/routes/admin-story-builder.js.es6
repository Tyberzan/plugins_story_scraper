import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class AdminStoryBuilderRoute extends DiscourseRoute {
  model() {
    return ajax("/story-builder/logs");
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.logs = model.logs;
  }
} 