@RestResource(urlMapping='/api/*')
global class PackageRouter {
	@HttpDelete
	global static void doDelete() {
		csutil.RestRouter.doDelete();
	}

	@HttpGet
	global static void doGet() {
		csutil.RestRouter.doGet();
	}

	@HttpPatch
	global static void doPatch() {
		csutil.RestRouter.doPatch();
	}

	@HttpPost
	global static void doPost() {
		csutil.RestRouter.doPost();
	}

	@HttpPut
	global static void doPut() {
		csutil.RestRouter.doPut();
	}
}
