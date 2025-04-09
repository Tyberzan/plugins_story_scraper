import Controller from "@ember/controller";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";

export default class AdminBuildnetController extends Controller {
  @tracked logs = [];
  @tracked loading = false;
  @tracked testingConnection = false;
  @tracked connectionStatus = null;
  @tracked topicId = null;
  @tracked userId = null;

  @action
  async testConnection() {
    this.testingConnection = true;
    this.connectionStatus = null;

    try {
      const result = await ajax("/buildnet/test_connection", {
        type: "POST",
      });
      this.connectionStatus = {
        success: true,
        message: I18n.t("buildnet.notifications.connection_success"),
      };
    } catch (error) {
      this.connectionStatus = {
        success: false,
        message: I18n.t("buildnet.notifications.connection_failure", {
          message: error.jqXHR.responseJSON?.errors || error,
        }),
      };
      popupAjaxError(error);
    } finally {
      this.testingConnection = false;
    }
  }

  @action
  async syncNow() {
    this.loading = true;

    try {
      await ajax("/buildnet/sync_all", {
        type: "POST",
      });
      this.flash(
        I18n.t("buildnet.notifications.sync_started"),
        "success"
      );
    } catch (error) {
      this.flash(
        I18n.t("buildnet.notifications.sync_failed", {
          message: error.jqXHR.responseJSON?.errors || error,
        }),
        "error"
      );
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  @action
  async syncTopic() {
    if (!this.topicId) {
      return;
    }

    this.loading = true;

    try {
      await ajax("/buildnet/sync_topic", {
        type: "POST",
        data: {
          topic_id: this.topicId,
        },
      });
      this.flash(
        I18n.t("buildnet.notifications.sync_started"),
        "success"
      );
    } catch (error) {
      this.flash(
        I18n.t("buildnet.notifications.sync_failed", {
          message: error.jqXHR.responseJSON?.errors || error,
        }),
        "error"
      );
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  @action
  async syncUser() {
    if (!this.userId) {
      return;
    }

    this.loading = true;

    try {
      await ajax("/buildnet/sync_user", {
        type: "POST",
        data: {
          user_id: this.userId,
        },
      });
      this.flash(
        I18n.t("buildnet.notifications.sync_started"),
        "success"
      );
    } catch (error) {
      this.flash(
        I18n.t("buildnet.notifications.sync_failed", {
          message: error.jqXHR.responseJSON?.errors || error,
        }),
        "error"
      );
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  @action
  async refreshLogs() {
    this.loading = true;

    try {
      const result = await ajax("/buildnet/logs");
      this.logs = result.logs;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }

  flash(message, type) {
    this.dialog.flash({ message, type });
  }
} 