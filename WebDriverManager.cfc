<!--- NOTES ON DRIVERS AND SERVICES

Webdrivers for each browser requires its own binary (webdriver) to "drive" the browser. They are created and maintained by the same organization that makes the browser.
The logic for instantiating each Selenium webdriver object is the same but configuring options for them can be different. The differences are both with the local webdriver as well as their respective service.

LOCAL WEBDRIVER:
Represents an idealised web browser and is meant for executing scripts living on YOUR machine against a browser (webdriver-binary and browser) running on YOUR machine.
The local webdrivers can only run headless and silently (without opening the browser and you seeing the tests).

When instantiated it starts the webdriver binary automatically but YOU have to shut it down with driver.quit().
For most drivers the webdriver binary used has to be set using setProperty() in "java.lang.System". 

You CAN also start the webdriver with a service but that seems to be undesired. If using a service the webdriver automatically starts the webdriver binary PLUS the service will also start a webdriver binary 
process when you invoke start() on it. And to shut both down you have to call both stop() and quit() on the webdriver and service respectively... It seems to primarily be meant for use with a remote webdriver.

REMOTE WEBDRIVER:
At the heart of it, it's the same as the local webdriver but meant for executing scripts on YOUR machine against a browser (webdriver-binary and Selenium server) running on a ANOTHER machine.
You can also initialize the remote webdriver with a service and point the service to your binary (using service.Builder.usingDriverExecutable) instead of using java.lang.System.setProperty().
When using the webdriver with a service you give RemoteWebDriver's init service.getUrl() as argument. When instantiated you have to start the service by invoking start() and shut it down again with stop().

With this you can visually see the tests but only if you start the webdriver-binary manually on your machine (taking away Selenium's control over the life and death of it). 
So despite the name you can use this locally. If you want to use it that way, then you give RemoteWebDriver's init "http://localhost:YOUR-PORT" as argument.

DRIVER SERVICE:
What exactly the benefit of using a service - outside of being able to specify what port to use - is still unclear to me. But I do know that for each test you're meant to create a brand new webdriver instance,
but that there's no reason to stop and start the webdriver binary. And supposedly it's easier to use the service to manage the webdriver binary, using to start the webdriver binary before all tests are executed
and stopping it after all tests are executed.

Despite the fact that it states in many places that this is usable remotely (as in with the webdriver binary on another machine) I can't really see how the service can manage that binary from one machine to
another. And you have to pass in the full path to the webdriver binary as part of the service instantiation. Surely you're not supposed to give it a network path to another machine? Very confusing... If you are
already running Selenium Grid on another machine, then THAT takes care of starting and stopping the binaries so it seems a service is only really useful for running multiple tests locally.

--->
<cfcomponent output="false" hint="An interface for creating Selenium's Java webdriver (org.openqa.selenium.remote.RemoteWebDriver) for specific browsers and platforms, and optionally a matching service (org.openqa.selenium.remote.service.DriverService)" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset aPlatforms = ["ANDROID","LINUX","MAC","WIN8_1","WIN8","WIN10","VISTA","WINDOWS"] />

	<!--- https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver --->
	<cfset stBrowserData.Chrome = {
		displayName: "Google Chrome",
		internalDriverName: "ChromeDriver",
		seleniumJavaPackageName: "chrome",
		downloadURLForBINs: "https://chromedriver.storage.googleapis.com/index.html",
		nameOfBinary: "chromedriver.exe",
		serviceJarName: "ChromeDriverService",
		browserOptionsJarName: "ChromeOptions",
		defaultPort: 9515
	} />

	<!--- https://github.com/SeleniumHQ/selenium/wiki/FirefoxDriver --->
	<cfset stBrowserData.Firefox = {
		displayName: "Mozilla Firefox",
		internalDriverName: "FirefoxDriver",
		seleniumJavaPackageName: "firefox",
		downloadURLForBINs: "https://github.com/mozilla/geckodriver/releases",
		nameOfBinary: "geckodriver.exe",
		serviceJarName: "GeckoDriverService",
		browserOptionsJarName: "FirefoxOptions",
		defaultPort: 4444
	} />

	<cfset stBrowserData.Edge = {
		displayName: "Microsoft Edge",
		internalDriverName: "edge",
		seleniumJavaPackageName: "chrome",
		downloadURLForBINs: "https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/",
		nameOfBinary: "MicrosoftWebDriver.exe",
		serviceJarName: "EdgeDriverService",
		browserOptionsJarName: "EdgeOptions",
		defaultPort: 17556
	} />

	<!--- https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver --->
	<cfset stBrowserData.InternetExplorer = {
		displayName: "Microsoft Internet Explorer",
		internalDriverName: "InternetExplorerDriver",
		seleniumJavaPackageName: "ie",
		downloadURLForBINs: "http://selenium-release.storage.googleapis.com",
		nameOfBinary: "IEDriverServer.exe",
		serviceJarName: "InternetExplorerDriverService",
		browserOptionsJarName: "InternetExplorerOptions",
		defaultPort: 5555
	} />

	<cffunction name="setPlatforms" returntype="void" access="private" >
		<cfargument name="data" type="array" required="yes" />

		<cfset aPlatforms = arguments.data />
	</cffunction>

	<cffunction name="getPlatforms" returntype="array" access="public" >
		<cfreturn aPlatforms />
	</cffunction>

	<cffunction name="setBrowserData" returntype="void" access="private" >
		<cfargument name="data" type="struct" required="yes" />

		<cfset stBrowserData = arguments.data />
	</cffunction>

	<cffunction name="getBrowsers" returntype="struct" access="public" >
		<cfreturn stBrowserData />
	</cffunction>

	<cffunction name="getBrowserData" returntype="struct" access="public" >
		<cfargument name="browser" type="string" required="yes" />

		<cfreturn stBrowserData[arguments.browser] />
	</cffunction>

	<cffunction name="verifyFilePath" returntype="boolean" access="private" >
		<cfargument name="filePath" type="string" required="yes" />

		<cfset var oFileRead = "" />
		<cftry>
			<cffile action="readbinary" file="#arguments.filePath#" variable="oFileRead" />
		<cfcatch>
			<cfreturn false />
		</cfcatch>
		</cftry>

		<cfreturn true />
	</cffunction>

	<cffunction name="isValidBrowser" returntype="boolean" access="private" >
		<cfargument name="browser" type="string" required="yes" default="" />

		<cfif structKeyExists(getBrowsers(), arguments.browser) >
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="isValidPlatform" returntype="boolean" access="private" >
		<cfargument name="platform" type="string" required="yes" default="" />

		<cfif arrayFind(getPlatforms(), arguments.platform) GT 0 >
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="createBrowser" returntype="Components.Browser" access="public" >
		<cfargument name="browser" type="string" required="yes" default="Name of the browser you'd like to create a webdriver for. See variables.stBrowserData for implemented browsers." />
		<cfargument name="remote" type="boolean" required="no" default="false" hint="Whether a local or remote version of the webdriver should be created. If your browser and tests will all run on the same machine then you do not need a the remote version. However if you combine manually starting the webdriver binaries with a remote webdriver you can visually see Selenium 'drive' your browser." />
		<cfargument name="remoteServerAddress" type="string" required="no" hint="Required if remote is true. The server address and port the remote webdriver should connect to. Note that Selenium will test the connection and throw an error if it can't connect to this address/port upon instantiation." />
		<cfargument name="platform" type="string" required="no" default="WINDOWS" hint="What platform you want the webdriver to run on. This is pretty close to the OS, but differs slightly, and is used to extract information such as program locations and line endings" />
		<cfargument name="browserVersion" type="numeric" required="false" default=0 hint="The version of the browser, or pass as empty if you don't know (or care for that matter)." />
		<cfargument name="browserArguments" type="array" required="no" default="#arrayNew(1)#" hint="An array of arguments specific to the browser that you want the webdriver to start with. NOTE: For the browsers that support it, you can get a noticable performance boost by disabling automatic proxy detection!" />
		<cfargument name="pathToWebDriverBIN" type="string" required="yes" hint="The full path to the webdriver executable" />
		<cfargument name="javaLoaderReference" type="any" required="false" />
		<cfargument name="loggingPreferences" type="Components.WebdriverLogSettings" required="false" />

		<cfset var oJavaLoader = "" />
		<cfset var oBrowser = "" />
		<cfset var stBrowserData = getBrowserData(arguments.browser) />
		<cfset var oBrowserCapabilities = createObject("java", "java.lang.Object") />
		<cfset var oBrowserDesiredCapabilities = createObject("java", "java.lang.Object") />
		<cfset var oBrowserOptions = createObject("java", "java.lang.Object") />
		<cfset var stBrowserArguments = structNew() />

		<cfset var oLoggingPreferences = createObject("java", "java.lang.Object") />
		<cfset var oLogType = createObject("java", "java.lang.Object") />
		<cfset var oLogLevel = createObject("java", "java.lang.Object") />
		<cfset var oCapabilityType = createObject("java", "java.lang.Object") />

		<cfif structKeyExists(arguments, "javaLoaderReference") AND isObject(arguments.javaLoaderReference) >
			<cfset oJavaLoader = arguments.javaLoaderReference />
		</cfif>

		<cfif isObject(oJavaLoader) >
			<cfset oBrowserOptions = oJavaLoader.create("org.openqa.selenium.#stBrowserData.seleniumJavaPackageName#.#stBrowserData.browserOptionsJarName#").init() />
			<cfset oBrowserDesiredCapabilities = oJavaLoader.create("org.openqa.selenium.remote.DesiredCapabilities") />
			<cfset stBrowserArguments.javaLoaderReference = arguments.javaLoaderReference />
		<cfelse>
			<cfset oBrowserOptions = createObject("java", "org.openqa.selenium.#stBrowserData.seleniumJavaPackageName#.#stBrowserData.browserOptionsJarName#").init() />
			<cfset oBrowserDesiredCapabilities = createObject("java", "org.openqa.selenium.remote.DesiredCapabilities") />
		</cfif>

		<cfif isValidBrowser(arguments.browser) IS false >
			<cfthrow message="Error while creating browser" detail="Argument 'Browser' which you passed as '#arguments.browser#' is not a valid browser name!" />
		</cfif>

		<cfif isValidPlatform(arguments.platform) IS false >
			<cfthrow message="Error while creating browser" detail="Argument 'Platform' which you passed as '#arguments.platform#' is not a valid platform name!" />
		</cfif>

		<cfif verifyFilePath(arguments.pathToWebDriverBIN) IS false >
			<cfthrow message="Error while creating browser" detail="The path you passed in 'PathToWebDriverBIN' as '#arguments.pathToWebDriverBIN#' is an invalid file-path or the binary can't be found or read!" />
		</cfif>

		<cfif arguments.remote >
			<cfif structKeyExists(arguments, "remoteServerAddress") IS false >
				<cfthrow message="Error while creating browser" detail="If you are passing argument 'Remote' as true then you must also pass argument 'RemoteServerAddress' as well" />
			<cfelse>
				<cftry>
					<cfset createObject("java", "java.net.URL").init( arguments.remoteServerAddress ) />

					<cfcatch type="java.net.MalformedURLException">
						<cfthrow message="Error while creating browser" detail="Either no legal protocol could be found in argument 'RemoteServerAddress' or it could not be parsed as a valid URL." />
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>

		<cfif arrayIsEmpty(arguments.browserArguments) EQ false AND listFindNoCase("chrome,firefox", arguments.browser) >
			<cfset oBrowserOptions.addArguments( arguments.browserArguments ) />
		</cfif>

		<cfset oBrowserCapabilities = invoke(oBrowserDesiredCapabilities, "#arguments.browser#") />  <!--- Thanks CF for not being able to call methods using bracket notation, both Railo and Lucee do better! --->
		<cfset oBrowserCapabilities.setCapability("platform", arguments.platform) />

		<cfif arguments.browserVersion GT 0 >
			<cfset oBrowserCapabilities.setCapability("version", "#arguments.browserVersion#") />
		<cfelse>
			<cfset oBrowserCapabilities.setCapability("version", "") />
		</cfif>

		<cfif structKeyExists(arguments, "loggingPreferences") >
			<!--- Note that different browsers may not implement all the different log types! --->
			<cfif isObject(oJavaLoader) >
				<cfset oCapabilityType = oJavaloader.create("org.openqa.selenium.remote.CapabilityType") />
			<cfelse>
				<cfset oCapabilityType = createObject("java", "org.openqa.selenium.remote.CapabilityType") />
			</cfif>

			<cfset oBrowserCapabilities.setCapability(oCapabilityType.LOGGING_PREFS, arguments.loggingPreferences.getJavaLogPreferences()) />
		</cfif>

		<!--- Browser specific behavior --->
		<cfif arguments.browser IS "Firefox" >

			<cfif isObject(oJavaLoader) >
				<cfset oBrowserOptions.setProfile( oJavaLoader.create("org.openqa.selenium.firefox.FirefoxProfile").init() ) />
			<cfelse>
				<cfset oBrowserOptions.setProfile( createObject("java", "org.openqa.selenium.firefox.FirefoxProfile").init() ) />
			</cfif>

			<cfset oBrowserOptions.addTo( oBrowserCapabilities ) />
		</cfif>
		<!--- End browser specific behaviour --->

		<cfset oBrowserCapabilities.setCapability(oBrowserOptions.CAPABILITY, oBrowserOptions) />

		<cfif arguments.remote >
			<cftry>

				<cfif isObject(oJavaLoader) >
					<cfset stBrowserArguments.webDriverReference = oJavaLoader.create("org.openqa.selenium.remote.RemoteWebDriver").init(
						createObject("java", "java.net.URL").init(arguments.remoteServerAddress),
						oBrowserCapabilities
					) />
				<cfelse>
					<cfset stBrowserArguments.webDriverReference = createObject("java", "org.openqa.selenium.remote.RemoteWebDriver").init(
						createObject("java", "java.net.URL").init(arguments.remoteServerAddress),
						oBrowserCapabilities
					) />
				</cfif>
				
			<cfcatch>
				<cfif cfcatch.type IS "org.openqa.selenium.remote.UnreachableBrowserException" >
					<cfthrow message="Error while creating browser" detail="Could not create a RemoteWebDriver instance. The server address and port likely couldn't be reached. You passed 'RemoteServerAddress' as: #arguments.RemoteServerAddress#" />
				</cfif>

				<cfif cfcatch.type IS "org.openqa.selenium.WebDriverException" AND structKeyExists(cfcatch, "message") AND FindNoCase("The requested URL /session was not found on this server", cfcatch.message) GT 0 >
					<cfthrow message="Error while creating browser" detail="Could not create a RemoteWebDriver instance. The remote address is reachable, but is not responding. Likely the port is missing, not open or not correct. You passed 'RemoteServerAddress' as: #arguments.RemoteServerAddress#" />
				</cfif>

				<cfrethrow/>
			</cfcatch>

			</cftry>
		<cfelse>
			<cfif arguments.browser IS "Firefox" >
				<cfset createObject("java", "java.lang.System").setProperty("webdriver.gecko.driver", arguments.pathToWebDriverBIN) />
			<cfelse>
				<cfset createObject("java", "java.lang.System").setProperty("webdriver.#lCase(arguments.browser)#.driver", arguments.pathToWebDriverBIN) />
			</cfif>

			<cfif isObject(oJavaLoader) >
				<cfset stBrowserArguments.webDriverReference = oJavaLoader.create("org.openqa.selenium.#LCase(arguments.browser)#.#stBrowserData.internalDriverName#").init(oBrowserCapabilities) />
			<cfelse>
				<cfset stBrowserArguments.webDriverReference = createObject("java", "org.openqa.selenium.#LCase(arguments.browser)#.#stBrowserData.internalDriverName#").init(oBrowserCapabilities) />
			</cfif>
		</cfif>
		<!--- Be aware that as SOON as the webdriver (either local or remote version) is invoked the webdriver binary will be started (and the browser opens, whether silent or not) --->

		<cfset oBrowser = createObject("component", "Components.Browser").init(
			argumentCollection = stBrowserArguments
		) />

		<cfreturn oBrowser />
	</cffunction>

	<cffunction name="createService" returntype="any" access="public" hint="The main benefit of using a service over just using the webdriver is efficiency and execution time. When webdriver.quit() is invoked without a service it shuts down the browser AND exist the webdriver binary. With a service it only shuts down the browser when calling service.stop() but keeps the binary running." >
		<cfargument name="browser" type="string" required="yes" hint="Name of the browser you'd like to create a service for" />
		<cfargument name="useAnyFreePort" type="boolean" required="false" default="false" hint="Let the service use any free port available. Will override the Port-argument if passed as true." />
		<cfargument name="port" type="numeric" required="no" default="0" hint="The port number you want the service to start the webdriver on. Will by default use the default port for the chosen browser's webdriver." />
		<cfargument name="pathToWebDriverBIN" type="string" required="no" hint="The full path to the webdriver executable. If not passed then the default location will be used (see mappings in Application.cfc)" />
		<cfargument name="javaLoaderReference" type="any" required="false" />

		<cfset var stBrowserData = getBrowserData(arguments.browser) />
		<cfset var oServiceBuilder = createObject("java", "java.lang.Object") />
		<cfset var oWebDriverService = createObject("java", "java.lang.Object") />
		<cfset var sPathToBIN = reReplace("#application.mapping.DriverBins##stBrowserData.nameOfBinary#", "[/|\\]", "\\", "ALL") />

		<cfif isObject(oJavaLoader) >
			<cfset oServiceBuilder = oJavaLoader.create("org.openqa.selenium.#lCase(arguments.browser)#.#stBrowserData.serviceJarName#$Builder") />
		<cfelse>
			<cfset oServiceBuilder = createObject("java", "org.openqa.selenium.#lCase(arguments.browser)#.#stBrowserData.serviceJarName#$Builder") />
		</cfif>

		<cfif structKeyExists(arguments, "pathToWebDriverBIN") >
			<cfif verifyFilePath(arguments.pathToWebDriverBIN) IS false >
				<cfthrow message="Error while creating browser" detail="The path you passed in 'PathToWebDriverBIN' as '#arguments.pathToWebDriverBIN#' is an invalid file-path or the binary can't be found or read!" />
			<cfelse>
				<cfset sPathToBIN = arguments.pathToWebDriverBIN />
			</cfif>
		</cfif>

		<cfif arguments.useAnyFreePort >
			<cfset oServiceBuilder.usingAnyFreePort() />

		<cfelseif arguments.Port IS NOT 0 >

			<cfif isValid("integer", arguments.port) IS false >
				<cfthrow message="Error while creating browser" detail="Argument 'Port' must be a valid integer!" />
			</cfif>
			<cfif arguments.port LT 0 >
				<cfthrow message="Error while creating browser" detail="Argument 'Port' must be greater than 0!" />
			</cfif>
			<cfset oServiceBuilder.usingPort( arguments.port ) />

		<cfelse>
			<cfset oServiceBuilder.usingPort( stBrowserData.defaultPort ) />
		</cfif>

		<cfset oServiceBuilder.usingDriverExecutable( createObject("java", "java.io.File").init(sPathToBIN) ) />
		<cfset oWebDriverService = oServiceBuilder.Build() />

		<cfif isObject(oWebDriverService) >
			<cfreturn oWebDriverService />
		<cfelse>
			<cfthrow message="Error while creating browser" detail="Something we can't indentify or catch went wrong with building the webdriver service. The service builder did not return an object." />
		</cfif>
	</cffunction>

</cfcomponent>