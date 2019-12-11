<cfcomponent output="false" modifier="final" hint="A wrapper for Selenium's various logging options. These can safety be passed to all browsers, but not all log settings are supported by every browser type." >

	<cfset variables.oJavaLoggingPreferences = nullValue() />
	<cfset variables.aLogSettings = [] />

	<cffunction name="getJavaLogPreferences" returntype="any" access="public" hint="" output="true" >
		<cfreturn variables.oJavaLoggingPreferences />
	</cffunction>

	<cffunction name="getLogSettings" returntype="array" access="public" hint="" >
		<cfreturn variables.aLogSettings />
	</cffunction>

	<cffunction name="init" returntype="WebdriverLogSettings" access="public" hint="" >
		<cfargument name="settings" type="array" required="true" hint="An array of arrays with 2 text entries: the log type, and the log level." />
		<cfargument name="seleniumFactory" type="SeleniumObjectFactory" required="true" />

		<!--- 
			Valid log levels:
			ALL, SEVERE (highest value), WARNING, INFO, CONFIG, FINE, FINER, FINEST (lowest value), OFF

			Valid log types:
			BROWSER, CLIENT, DRIVER, PERFORMANCE, PROFILER, SERVER
		--->

		<cfset var oLoggingPreferences = arguments.seleniumFactory.get("org.openqa.selenium.logging.LoggingPreferences").init() />
		<cfset var oLogType = arguments.seleniumFactory.get("org.openqa.selenium.logging.LogType") />
		<cfset var oLogLevel = createObject("java", "java.util.logging.Level") />

		<cfloop array="#arguments.settings#" index="aCurrentSetting" >
			<cfif NOT isArray(aCurrentSetting) >
				<cfthrow message="Couldn't create logging preferences" detail="The current index in argument 'settings' is not an array: #getMetadata(arguments.settings).getName()#" />
			</cfif>

			<cfif arrayLen(aCurrentSetting) LTE 1 >
				<cfthrow message="Couldn't create logging preferences" detail="The current index in argument 'settings' has less than 2 entries" />
			</cfif>

			<cfif NOT isInstanceOf(aCurrentSetting[1], "java.lang.String") >
				<cfthrow message="Couldn't create logging preferences" detail="The first entry in the current index in argument 'settings' is not a string: #getMetadata(arguments.settings).getName()#" />
			</cfif>

			<cfif NOT isInstanceOf(aCurrentSetting[2], "java.lang.String") >
				<cfthrow message="Couldn't create logging preferences" detail="The second entry in the current index in argument 'settings' is not a string: #getMetadata(arguments.settings).getName()#" />
			</cfif>

			<cfif structKeyExists(oLogType, uCase(aCurrentSetting[1])) IS false >
				<cfthrow message="Couldn't create logging preferences" detail="The first entry in the current index in argument 'settings' is not a valid log type: #aCurrentSetting[1]#" />
			</cfif>

			<cfif structKeyExists(oLogLevel, uCase(aCurrentSetting[2])) IS false >
				<cfthrow message="Couldn't create logging preferences" detail="The second entry in the current index in argument 'settings' is not a valid log level: #aCurrentSetting[2]#" />
			</cfif>

			<cfset oLoggingPreferences.enable(oLogType[uCase(aCurrentSetting[1])], oLogLevel[uCase(aCurrentSetting[2])]) />
		</cfloop>

		<cfset variables.oJavaLoggingPreferences = oLoggingPreferences />
		<cfset variables.aLogSettings = arguments.settings />

		<cfreturn this />
	</cffunction>

</cfcomponent>