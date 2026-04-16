// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom("controllers", application);

// Marksmith markdown editor
import { MarksmithController } from "@avo-hq/marksmith";
application.register("marksmith", MarksmithController);
