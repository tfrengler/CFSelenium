<cfcomponent output="false" hint="" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaLoggingPreferences = "" />
	<cfset aLogSettings = arrayNew(1) />

	<cffunction name="getJavaLogPreferences" returntype="any" access="public" hint="" output="true" >
		<cfreturn variables.oJavaLoggingPreferences />
	</cffunction>

	<cffunction name="getLogSettings" returntype="array" access="public" hint="" >
		<cfreturn variables.aLogSettings />
	</cffunction>

	<cffunction name="init" returntype="Components.WebdriverLogSettings" access="public" hint="" >
		<cfargument name="settings" type="array" required="true" hint="An array of arrays with 2 text entries: the log type, and the log level." />
		<cfargument name="javaLoader" type="any" required="false" hint="A reference to Mark Mandel's Javaloader-component" />

		<!--- 
			Valid log levels:
			ALL, SEVERE (highest value), WARNING, INFO, CONFIG, FINE, FINER, FINEST (lowest value), OFF

			Valid log types:
			BROWSER, CLIENT, DRIVER, PERFORMANCE, PROFILER, SERVER
		--->

		<cfset var oLoggingPreferences = "" />
		<cfset var oLogType = "" />
		<cfset var oLogLevel = createObject("java", "java.util.logging.Level") />

		<cfif structKeyExists(arguments, "javaLoader") AND isObject(arguments.javaLoader) >
			<cfset oLoggingPreferences = arguments.javaLoader.create("org.openqa.selenium.logging.LoggingPreferences").init() />
			<cfset oLogType = arguments.javaLoader.create("org.openqa.selenium.logging.LogType") />
		<cfelse>
			<cfset oLoggingPreferences = createObject("java", "org.openqa.selenium.logging.LoggingPreferences").init() />
			<cfset oLogType = createObject("java", "org.openqa.selenium.logging.LogType") />
		</cfif>

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