//
//  CODCrashTemplates.swift
//  Preferences
//
//  Verbatim structure of real Call of Duty: Mobile watchdog crash reports
//  (bug_type 309, EXC_CRASH / SIGKILL, 0x8BADF00D), with every
//  device- and run-specific value replaced by a placeholder token.
//  `CrashReportGenerator` fills the tokens in, so nothing personal is
//  stored in the repository and every generated report matches the
//  device shown in Settings > General > About.
//

enum CODCrashTemplates {
    /// All templates, in no particular order — the generator picks one per report.
    static let all: [String] = [templateA, templateB, templateC]

    /// 53 threads, 65 loaded images.
    static let templateA = #"""
{"app_name":"cod","timestamp":"{{TIMESTAMP}}","app_version":"{{APP_VERSION}}","slice_uuid":"{{SLICE_UUID}}","adam_id":"1287282214","build_version":"{{APP_BUILD}}","bundleID":"com.activision.callofduty.shooter","platform":2,"share_with_app_devs":1,"is_first_party":0,"bug_type":"309","os_version":"{{OS_VERSION_FULL}}","roots_installed":0,"incident_id":"{{INCIDENT}}","name":"cod"}
{
  "uptime" : {{UPTIME}},
  "procRole" : "Non UI",
  "version" : 2,
  "userID" : 501,
  "deployVersion" : 210,
  "modelCode" : "{{MODEL_CODE}}",
  "coalitionID" : {{COALITION_ID}},
  "osVersion" : {
    "isEmbedded" : true,
    "train" : "{{OS_TRAIN}}",
    "releaseType" : "User",
    "build" : "{{OS_BUILD}}"
  },
  "captureTime" : "{{CAPTURE_TIME}}",
  "codeSigningMonitor" : 1,
  "incident" : "{{INCIDENT}}",
  "pid" : {{PID}},
  "translated" : false,
  "cpuType" : "ARM-64",
  "procLaunch" : "{{PROC_LAUNCH}}",
  "procStartAbsTime" : {{PROC_START_ABS}},
  "procExitAbsTime" : {{PROC_EXIT_ABS}},
  "procName" : "cod",
  "procPath" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/cod",
  "bundleInfo" : {"CFBundleShortVersionString":"{{APP_VERSION}}","CFBundleVersion":"{{APP_BUILD}}","CFBundleIdentifier":"com.activision.callofduty.shooter","DTAppStoreToolsBuild":"17F106"},
  "storeInfo" : {"itemID":"1287282214","storeCohortMetadata":"{{STORE_COHORT}}","distributorID":"com.apple.AppStore","deviceIdentifierForVendor":"{{IDFV}}","softwareVersionExternalIdentifier":"{{SW_EXT_ID}}","applicationVariant":"1:{{MODEL_CODE}}:18","thirdParty":true},
  "parentProc" : "launchd",
  "parentPid" : 1,
  "coalitionName" : "com.activision.callofduty.shooter",
  "crashReporterKey" : "{{CRASH_REPORTER_KEY}}",
  "appleIntelligenceStatus" : {"state":"available"},
  "bootProgressRegister" : "0x20800004",
  "wasUnlockedSinceBoot" : 1,
  "isLocked" : 0,
  "codeSigningID" : "com.activision.callofduty.shooter",
  "codeSigningTeamID" : "6KZFBJ4CBY",
  "codeSigningFlags" : 570450689,
  "codeSigningValidationCategory" : 4,
  "codeSigningTrustLevel" : 7,
  "codeSigningAuxiliaryInfo" : 0,
  "instructionByteStream" : {"beforePC":"fyMD1f17v6n9AwCRuwAAlL8DAJH9e8Go\/w9f1sADX9YwJoDSARAA1A==","atPC":"AwEAVH8jA9X9e7+p\/QMAkcIAAJS\/AwCR\/XvBqP8PX9bAA1\/WkCqA0g=="},
  "bootSessionUUID" : "{{BOOT_SESSION}}",
  "exception" : {"codes":"0x0000000000000000, 0x0000000000000000","rawCodes":[0,0],"type":"EXC_CRASH","signal":"SIGKILL"},
  "termination" : {"code":2343432205,"flags":6,"namespace":"FRONTBOARD","reasons":["<RBSTerminateContext| domain:10 code:0x8BADF00D explanation:[app<com.activision.callofduty.shooter>:{{PID}}] Failed to terminate gracefully after 5.0s","ProcessVisibility: Unknown","ProcessState: Running","WatchdogEvent: process-exit","WatchdogVisibility: Background","WatchdogCPUStatistics: (","\"Elapsed total CPU time (seconds): {{CPU_TOTAL}} (user {{CPU_USER}}, system {{CPU_SYS}}), {{CPU_PCT}}% CPU\",","\"Elapsed application CPU time (seconds): {{CPU_APP}}, {{CPU_APP_PCT}}% CPU\"",")","ThermalInfo: (","\"Thermal Level:   0\",","\"Thermal State:   nominal\"",") reportType:CrashLog maxTerminationResistance:Interactive>"]},
  "faultingThread" : 0,
  "threads" : [{"triggered":true,"id":{{TID}},"threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6096985720},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":8723964352,"symbolLocation":0,"symbol":"_main_thread"},{"value":0},{"value":5809501960},{"value":5809502024},{"value":8723964576,"symbolLocation":224,"symbol":"_main_thread"},{"value":0},{"value":0},{"value":0},{"value":1},{"value":256},{"value":3777893186295716171},{"value":4294967295}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6096985840},"sp":{"value":6096985696},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816,"matchesCrashFrame":1},"far":{"value":0}},"queue":"com.apple.main-thread","frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":154559212,"imageIndex":0},{"imageOffset":154542520,"imageIndex":0},{"imageOffset":154937848,"imageIndex":0},{"imageOffset":154910068,"imageIndex":0},{"imageOffset":163598636,"imageIndex":0},{"imageOffset":164208132,"imageIndex":0},{"imageOffset":96144,"imageIndex":0},{"imageOffset":446724,"symbol":"-[GCloudAppLifecycleDispatcher gcloud_applicationWillTerminate:]","symbolLocation":108,"imageIndex":17},{"imageOffset":23072064,"symbol":"-[UIApplication _terminateWithStatus:]","symbolLocation":196,"imageIndex":49},{"imageOffset":1670180,"symbol":"-[_UISceneLifecycleMultiplexer _evalTransitionToSettings:fromSettings:forceExit:withTransitionStore:]","symbolLocation":108,"imageIndex":49},{"imageOffset":14273860,"symbol":"-[_UISceneLifecycleMultiplexer forceExitWithTransitionContext:scene:]","symbolLocation":156,"imageIndex":49},{"imageOffset":23060408,"symbol":"-[UIApplication workspaceShouldExit:withTransitionContext:]","symbolLocation":180,"imageIndex":49},{"imageOffset":368636,"symbol":"__63-[FBSWorkspaceScenesClient willTerminateWithTransitionContext:]_block_invoke","symbolLocation":76,"imageIndex":50},{"imageOffset":148768,"symbol":"-[FBSWorkspace _calloutQueue_executeCalloutFromSource:withBlock:]","symbolLocation":176,"imageIndex":50},{"imageOffset":111076,"symbol":"_dispatch_client_callout","symbolLocation":16,"imageIndex":51},{"imageOffset":26260,"symbol":"_dispatch_block_invoke_direct","symbolLocation":284,"imageIndex":51},{"imageOffset":180100,"symbol":"__BSSERVICEMAINRUNLOOPQUEUE_IS_CALLING_OUT_TO_A_BLOCK__","symbolLocation":52,"imageIndex":52},{"imageOffset":179712,"symbol":"BSServiceMainRunLoopSourceHandler","symbolLocation":224,"imageIndex":52},{"imageOffset":656272,"symbol":"__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__","symbolLocation":28,"imageIndex":53},{"imageOffset":656132,"symbol":"__CFRunLoopDoSource0","symbolLocation":172,"imageIndex":53},{"imageOffset":415292,"symbol":"__CFRunLoopDoSources0","symbolLocation":332,"imageIndex":53},{"imageOffset":192928,"symbol":"__CFRunLoopRun","symbolLocation":820,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":5272,"symbol":"GSEventRunModal","symbolLocation":120,"imageIndex":54},{"imageOffset":1185392,"symbol":"-[UIApplication _run]","symbolLocation":796,"imageIndex":49},{"imageOffset":573784,"symbol":"UIApplicationMain","symbolLocation":332,"imageIndex":49},{"imageOffset":16592,"imageIndex":0},{"imageOffset":19484,"symbol":"start","symbolLocation":6928,"imageIndex":55}]},{"id":{{TID}},"name":"com.apple.uikit.eventfetch-thread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":59386512801792},{"value":0},{"value":59386512801792},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":13827},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8750562800},{"value":0},{"value":4294967295},{"value":2},{"value":59386512801792},{"value":0},{"value":59386512801792},{"value":21592279046},{"value":6100409736},{"value":8589934592},{"value":18446744073709550527},{"value":11205083136,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9893466892},"cpsr":{"value":4096},"fp":{"value":6100409584},"sp":{"value":6100409504},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893453012},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":57},{"imageOffset":43992,"symbol":"-[NSRunLoop(NSRunLoop) runUntilDate:]","symbolLocation":64,"imageIndex":57},{"imageOffset":945836,"symbol":"-[UIEventFetcher threadMain]","symbolLocation":420,"imageIndex":49},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"TDM-report-1","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095732855128},{"value":0},{"value":6104428240},{"value":6104428256},{"value":3435973837},{"value":2},{"value":1374389535},{"value":50},{"value":0},{"value":1},{"value":1},{"value":9774}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":1610616832},"fp":{"value":6104428224},"sp":{"value":6104428176},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":59},{"imageOffset":206100,"symbol":"TDM::TDataMasterReporter::LoopReportData()","symbolLocation":392,"imageIndex":10},{"imageOffset":205056,"symbol":"TDM::TDataMasterReporter::ProcessSingleThread(void*)","symbolLocation":64,"imageIndex":10},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":59},{"imageOffset":134980,"symbol":"MSDKScriptVM_LoadVMWithCallback","symbolLocation":648,"imageIndex":19},{"imageOffset":747976,"symbol":"initPixVM(void*)","symbolLocation":148,"imageIndex":19},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":18446744072631617535},{"value":18446726482597246976},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":15},{"value":2607872},{"value":4811678144},{"value":8723985664,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSArray0"},{"value":8723985664,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSArray0"},{"value":334},{"value":6955201240,"symbolLocation":0,"symbol":"-[__NSArray0 release]"},{"value":0},{"value":0},{"value":6105001328},{"value":4626673664,"symbolLocation":16,"symbol":"msdk_puerts::ClassDefineBuilder<JSLoggerInterface> msdk_puerts::DefineClass<JSLoggerInterface>()::NameLiteral"},{"value":1},{"value":2},{"value":8753920840,"symbolLocation":0,"symbol":"__NSArray0__struct"},{"value":8962507416,"objc-selector":"countByEnumeratingWithState:objects:count:"},{"value":0},{"value":4626401756},{"value":4626673664,"symbolLocation":16,"symbol":"msdk_puerts::ClassDefineBuilder<JSLoggerInterface> msdk_puerts::DefineClass<JSLoggerInterface>()::NameLiteral"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6105001312},"sp":{"value":6105001264},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}}},{"id":{{TID}},"name":"OperationQueue.ThreadProcess","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6105575112},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":4729061095732855128},{"value":0},{"value":4762667704},{"value":4762667768},{"value":6105575648},{"value":0},{"value":0},{"value":0},{"value":0},{"value":512},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6105575232},"sp":{"value":6105575088},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":215812,"symbol":"ABase::CCondition::Wait()","symbolLocation":52,"imageIndex":17},{"imageOffset":215276,"symbol":"ABase::OperationQueueImp::onThreadProc(void*)","symbolLocation":348,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"OperationQueue.ThreadProcess","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6106148552},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":4729061095732855128},{"value":0},{"value":4762667704},{"value":4762667768},{"value":6106149088},{"value":0},{"value":0},{"value":0},{"value":1},{"value":256},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6106148672},"sp":{"value":6106148528},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":215812,"symbol":"ABase::CCondition::Wait()","symbolLocation":52,"imageIndex":17},{"imageOffset":215276,"symbol":"ABase::OperationQueueImp::onThreadProc(void*)","symbolLocation":348,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"OperationQueue.ThreadManager","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":4764077264},{"value":18446726482597246976},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095732855128},{"value":0},{"value":0},{"value":6106722112},{"value":4762667768},{"value":4762667656},{"value":0},{"value":4760800816},{"value":0},{"value":4624068608,"symbolLocation":56,"symbol":"vtable for ABase::_tagApolloActionBufferBase"},{"value":10},{"value":1788184552620}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6106722096},"sp":{"value":6106722048},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":215672,"symbol":"ABase::SleepMS(long long)","symbolLocation":80,"imageIndex":17},{"imageOffset":214752,"symbol":"ABase::OperationQueueImp::onThreadManageProc(void*)","symbolLocation":428,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"XLogThread","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":65704},{"value":86399},{"value":999999000},{"value":6107295384},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":2},{"value":0},{"value":4812822336},{"value":4812822464},{"value":6107295968},{"value":999999000},{"value":86399},{"value":0},{"value":1},{"value":256},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6107295504},"sp":{"value":6107295360},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":187356,"symbol":"ABase::CCondition::TimeWait(unsigned int)","symbolLocation":172,"imageIndex":17},{"imageOffset":184984,"symbol":"ABase::Logger::_XLogThread(void*)","symbolLocation":60,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"CThreadBase","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":79561104625927770},{"value":24000000},{"value":103515},{"value":0},{"value":0},{"value":334},{"value":4729061095732855128},{"value":0},{"value":0},{"value":6107868944},{"value":4819806272},{"value":4819806200},{"value":4819806344},{"value":4623890462,"symbolLocation":25336,"symbol":"ABase::base64_chars2"},{"value":4623880239,"symbolLocation":15113,"symbol":"ABase::base64_chars2"},{"value":1},{"value":4623891094,"symbolLocation":25968,"symbol":"ABase::base64_chars2"},{"value":4623891186,"symbolLocation":26060,"symbol":"ABase::base64_chars2"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6107868928},"sp":{"value":6107868880},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":285468,"symbol":"ABase::CThreadBase::Sleep(int)","symbolLocation":84,"imageIndex":17},{"imageOffset":233208,"symbol":"ABase::CTimerImp::OnThreadProc()","symbolLocation":168,"imageIndex":17},{"imageOffset":284812,"symbol":"ABase::CThreadBase::onThreadProc(void*)","symbolLocation":704,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GC Finalizer","threadState":{"x":[{"value":260},{"value":0},{"value":47616},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6108442168},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":23089744188928},{"value":0},{"value":4760938184},{"value":4760938248},{"value":6108442848},{"value":0},{"value":0},{"value":47616},{"value":47617},{"value":47872},{"value":3777893186295716171},{"value":4294967295}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6108442288},"sp":{"value":6108442144},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":154559212,"imageIndex":0},{"imageOffset":154301356,"imageIndex":0},{"imageOffset":154542320,"imageIndex":0},{"imageOffset":154569268,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"Loading.AsyncRead","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":4809703440},{"value":0},{"value":4560112864},{"value":574},{"value":574},{"value":35843},{"value":18446744073709551615},{"value":6595970256563970},{"value":4294967293},{"value":1535744},{"value":0},{"value":1535744},{"value":6595970256563968},{"value":18446744073709551580},{"value":39850749952},{"value":0},{"value":4821796400},{"value":4821796336},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":6109589200},"sp":{"value":6109589184},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":158991972,"imageIndex":0},{"imageOffset":158990420,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"com.apple.NSURLConnectionLoader","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":284786396495872},{"value":0},{"value":284786396495872},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":66307},{"value":20480},{"value":87960930242560},{"value":18446744073709551569},{"value":8750562800},{"value":0},{"value":4294967295},{"value":2},{"value":284786396495872},{"value":0},{"value":284786396495872},{"value":21592279046},{"value":6115319112},{"value":8589934592},{"value":18446744073709550527},{"value":11205083136,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9893466892},"cpsr":{"value":4096},"fp":{"value":6115318960},"sp":{"value":6115318880},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893453012},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":596820,"symbol":"+[__CFN_CoreSchedulingSetRunnable _run:]","symbolLocation":416,"imageIndex":60},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"UnityGfxDeviceWorker","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":68719460488},{"value":5737925632},{"value":0},{"value":0},{"value":0},{"value":67611},{"value":18446744073709551615},{"value":2302516},{"value":4529215808},{"value":1803},{"value":150554712268415168},{"value":337920},{"value":4682006528},{"value":18446744073709551580},{"value":6141208768},{"value":0},{"value":5229064128},{"value":5229064064},{"value":18446744073709551615},{"value":4822988868},{"value":6111930093712},{"value":10000},{"value":2302516},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":6103853952},"sp":{"value":6103853936},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":162637164,"imageIndex":0},{"imageOffset":159317192,"imageIndex":0},{"imageOffset":164673120,"imageIndex":0},{"imageOffset":159350252,"imageIndex":0},{"imageOffset":159316944,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"com.apple.CoreMotion.MotionThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":538773582512128},{"value":0},{"value":538773582512128},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":125443},{"value":512},{"value":2199023256064},{"value":18446744073709551569},{"value":8750562800},{"value":0},{"value":4294967295},{"value":2},{"value":538773582512128},{"value":0},{"value":538773582512128},{"value":21592279046},{"value":6122199320},{"value":8589934592},{"value":18446744073709550527},{"value":11205083136,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9893466892},"cpsr":{"value":4096},"fp":{"value":6122199168},"sp":{"value":6122199088},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893453012},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":912868,"symbol":"CFRunLoopRun","symbolLocation":64,"imageIndex":53},{"imageOffset":91516,"imageIndex":61},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"mgpa_handler","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":520081884839936},{"value":0},{"value":520081884839936},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":121091},{"value":768},{"value":3298534884096},{"value":18446744073709551569},{"value":8750562800},{"value":0},{"value":4294967295},{"value":2},{"value":520081884839936},{"value":0},{"value":520081884839936},{"value":21592279046},{"value":6123658648},{"value":8589934592},{"value":18446744073709550527},{"value":11205083136,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9893466892},"cpsr":{"value":4096},"fp":{"value":6123658496},"sp":{"value":6123658416},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893453012},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":57},{"imageOffset":62204,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":64,"imageIndex":57},{"imageOffset":27520,"symbol":"-[MGPAMsgServer startMainHandlerRunloop]","symbolLocation":244,"imageIndex":44},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"APM-IOS-WorkThread","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":63},{"value":2607872},{"value":5828921840},{"value":72057602761913441,"symbolLocation":72057594037927937,"symbol":"OBJC_CLASS_$___NSCFString"},{"value":8723985504,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSCFString"},{"value":334},{"value":6955105796,"symbolLocation":0,"symbol":"-[__NSCFString release]"},{"value":0},{"value":6124234544},{"value":6124234560},{"value":4621348307},{"value":8963028888,"objc-selector":"sharedManager"},{"value":4621348350},{"value":4621348626},{"value":4763772672},{"value":8948484376,"objc-selector":"sharedInstance"},{"value":9444},{"value":4621348504}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":1610616832},"fp":{"value":6124234528},"sp":{"value":6124234480},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":59},{"imageOffset":193144,"symbol":"-[TApmApiSingleInstance startWorkThread]","symbolLocation":2784,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"APM-IOS-UploadThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":96},{"value":18446726483666796544},{"value":15582673472},{"value":6124804456},{"value":6124804452},{"value":6124804440},{"value":119059},{"value":18446744073709551615},{"value":0},{"value":0},{"value":271770873919462300},{"value":271753279585931840},{"value":284672},{"value":4682006528},{"value":18446744073709551580},{"value":53005693504},{"value":0},{"value":5327970096},{"value":5327970032},{"value":18446744073709551615},{"value":8948484376,"objc-selector":"sharedInstance"},{"value":4621327423},{"value":4621334769},{"value":4621334838},{"value":15582666912},{"value":15582666912},{"value":5328621312}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":6124809296},"sp":{"value":6124809280},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":196656,"symbol":"-[TApmApiSingleInstance startUploadThread]","symbolLocation":132,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ace_schedule3","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":6101560944},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":4614781600},{"value":3801571820184469556},{"value":6},{"value":3998368724},{"value":24000000},{"value":4562787},{"value":1024},{"value":4398046512128},{"value":93},{"value":8750560056},{"value":0},{"value":5192826176},{"value":0},{"value":1},{"value":0},{"value":3266728883},{"value":2756327217},{"value":4617043008},{"value":2032324052},{"value":342936582},{"value":38274408}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4614808752},"cpsr":{"value":2684358656},"fp":{"value":6101561056},"sp":{"value":6101560800},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893483376},"far":{"value":0}},"frames":[{"imageOffset":33648,"symbol":"__select","symbolLocation":8,"imageIndex":47},{"imageOffset":550064,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":59},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1439664,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":60},{"value":0},{"value":52},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":8750560552},{"value":0},{"value":6125383440},{"value":6125383456},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":1610616832},"fp":{"value":6125383424},"sp":{"value":6125383376},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}}},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":59},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1617160,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":3},{"value":0},{"value":52},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095732855128},{"value":0},{"value":6125956480},{"value":6125956496},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":1610616832},"fp":{"value":6125956464},"sp":{"value":6125956416},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}}},{"id":{{TID}},"name":"ace_worker0","threadState":{"x":[{"value":4},{"value":0},{"value":73896},{"value":68719460488},{"value":0},{"value":0},{"value":52},{"value":0},{"value":1},{"value":4},{"value":5},{"value":4294967293},{"value":1024},{"value":0},{"value":1024},{"value":4398046512128},{"value":271},{"value":1},{"value":0},{"value":5230143488},{"value":0},{"value":5230143640},{"value":4617043952},{"value":2835083243},{"value":1379020717},{"value":675135217},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4614823544},"cpsr":{"value":536875008},"fp":{"value":6126530272},"sp":{"value":6126530192},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893535724},"far":{"value":0}},"frames":[{"imageOffset":85996,"symbol":"sem_wait","symbolLocation":8,"imageIndex":47},{"imageOffset":564856,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"caulk::deferred_logger","threadState":{"x":[{"value":14},{"value":1152851136131088384},{"value":0},{"value":1},{"value":0},{"value":1},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":5305679896},{"value":18446744073709551615},{"value":268419072},{"value":6098120424},{"value":18446744073709551580},{"value":18},{"value":0},{"value":5230237880},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11681475692},"cpsr":{"value":2147487744},"fp":{"value":6098120576},"sp":{"value":6098120544},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":62},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":62},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":62},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"caulk.messenger.shared:high","threadState":{"x":[{"value":14},{"value":27915},{"value":27915},{"value":19},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":1},{"value":5328609064},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":12006804344},{"value":0},{"value":5230236512},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11681475692},"cpsr":{"value":2147487744},"fp":{"value":6102134656},"sp":{"value":6102134624},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":62},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":62},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":62},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ausm_messenger_for_buffer_disposal","threadState":{"x":[{"value":14},{"value":4764808595},{"value":0},{"value":6099267699},{"value":4764808560},{"value":34},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":6099267584},{"value":0},{"value":5634201784},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11681475692},"cpsr":{"value":2147487744},"fp":{"value":6099267456},"sp":{"value":6099267424},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":62},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":62},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":62},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":59},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1594748,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095732855128},{"value":0},{"value":6128824080},{"value":6128824096},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":1610616832},"fp":{"value":6128824064},"sp":{"value":6128824016},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}}},{"id":{{TID}},"name":"GThreadProcess","threadState":{"x":[{"value":4},{"value":0},{"value":94313728},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6129396008},{"value":0},{"value":60388608},{"value":259367096471352578},{"value":259367096471352578},{"value":60388608},{"value":0},{"value":259367096471352576},{"value":305},{"value":4729061095732855128},{"value":0},{"value":5873807448},{"value":5873807512},{"value":6129397984},{"value":0},{"value":0},{"value":94313728},{"value":94313729},{"value":94313984},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6129396128},"sp":{"value":6129395984},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":105896,"imageIndex":32},{"imageOffset":104632,"imageIndex":32},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GThreadProcess","threadState":{"x":[{"value":260},{"value":0},{"value":94313728},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6129969448},{"value":0},{"value":60388608},{"value":259367096471352578},{"value":259367096471352578},{"value":60388608},{"value":0},{"value":259367096471352576},{"value":305},{"value":4729061095732855128},{"value":0},{"value":5873807448},{"value":5873807512},{"value":6129971424},{"value":0},{"value":0},{"value":94313728},{"value":94313728},{"value":94314240},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6129969568},"sp":{"value":6129969424},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":105896,"imageIndex":32},{"imageOffset":104632,"imageIndex":32},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GThreadManager","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":0},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":10},{"value":10},{"value":0},{"value":60388608},{"value":259367096471352576},{"value":334},{"value":4729061095732855128},{"value":0},{"value":0},{"value":6130543056},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6130543024},"sp":{"value":6130542976},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":105540,"imageIndex":32},{"imageOffset":102668,"imageIndex":32},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ace_rp_queue","threadState":{"x":[{"value":4},{"value":0},{"value":96},{"value":18446726483666796544},{"value":1},{"value":9},{"value":0},{"value":0},{"value":1},{"value":4289812312},{"value":0},{"value":0},{"value":5235211610776053927},{"value":5235194016442524262},{"value":960512},{"value":4682006528},{"value":271},{"value":44867750502},{"value":0},{"value":5229900544},{"value":0},{"value":65536},{"value":5229901080},{"value":5670076416},{"value":0},{"value":3435973837},{"value":214748364},{"value":1717986919},{"value":446}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4614870828},"cpsr":{"value":2684358656},"fp":{"value":6114176736},"sp":{"value":6114176656},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893535724},"far":{"value":0}},"frames":[{"imageOffset":85996,"symbol":"sem_wait","symbolLocation":8,"imageIndex":47},{"imageOffset":612140,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GVoiceUtil","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":0},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":256},{"value":0},{"value":256},{"value":1099511628032},{"value":334},{"value":8750562800},{"value":0},{"value":0},{"value":6132264832},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6132264816},"sp":{"value":6132264768},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":59},{"imageOffset":175815176,"imageIndex":0},{"imageOffset":174221216,"symbol":"ApolloTVE::CSysThread::GSysThreadProc(void*)","symbolLocation":24,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GVoiceCapture","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":3543824036068086856},{"value":18446726482597246976},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":10752},{"value":0},{"value":10752},{"value":46179488377344},{"value":334},{"value":6132838400},{"value":0},{"value":0},{"value":6132829952},{"value":5816620824},{"value":1},{"value":6132830016},{"value":4},{"value":0},{"value":4},{"value":5816722563},{"value":5816711664}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6132829936},"sp":{"value":6132829888},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":59},{"imageOffset":175549688,"imageIndex":0},{"imageOffset":174221216,"symbol":"ApolloTVE::CSysThread::GSysThreadProc(void*)","symbolLocation":24,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GVoiceCdnv","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":0},{"value":18446726482597246976},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":15616},{"value":0},{"value":15616},{"value":67070209309952},{"value":334},{"value":8750560056},{"value":0},{"value":0},{"value":6133411632},{"value":4762524896},{"value":4762524696},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":2684358656},"fp":{"value":6133411616},"sp":{"value":6133411568},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":59},{"imageOffset":177054480,"imageIndex":0},{"imageOffset":177038000,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"JavaScriptCore libpas scavenger","threadState":{"x":[{"value":260},{"value":0},{"value":409860352},{"value":0},{"value":0},{"value":160},{"value":9},{"value":999996984},{"value":6133984936},{"value":0},{"value":99072},{"value":425511000048386},{"value":425511000048386},{"value":99072},{"value":0},{"value":425511000048384},{"value":305},{"value":8750562544},{"value":0},{"value":5940619328},{"value":5940619392},{"value":6133985504},{"value":999996984},{"value":9},{"value":409860352},{"value":409862145},{"value":409862400},{"value":0},{"value":8727855104,"symbolLocation":0,"symbol":"WTF::globalMaxQOSclass"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8558267208},"cpsr":{"value":1610616832},"fp":{"value":6133985056},"sp":{"value":6133984912},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893475816},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":29667316,"symbol":"scavenger_thread_main","symbolLocation":1632,"imageIndex":63},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"Log work queue","threadState":{"x":[{"value":14},{"value":6157246464},{"value":1},{"value":0},{"value":8689336592,"symbolLocation":0,"symbol":"_os_log_current_test_callback"},{"value":12},{"value":0},{"value":6113030368},{"value":0},{"value":0},{"value":0},{"value":5696078864},{"value":6157238272},{"value":3739187587},{"value":1},{"value":6157238272},{"value":18446744073709551580},{"value":8750507488},{"value":0},{"value":6141985792},{"value":6141985832},{"value":6113030144},{"value":0},{"value":0},{"value":6142034432},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7430992276},"cpsr":{"value":2147487744},"fp":{"value":6113029968},"sp":{"value":6113029936},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":19763604,"symbol":"WTF::Detail::CallableWrapper<IPC::StreamConnectionWorkQueue::startProcessingThread()::$_0, void>::call()","symbolLocation":52,"imageIndex":64},{"imageOffset":995056,"symbol":"WTF::Thread::entryPoint(WTF::Thread::NewThreadContext*)","symbolLocation":356,"imageIndex":63},{"imageOffset":1009320,"symbol":"WTF::wtfThreadEntryPoint(void*)","symbolLocation":16,"imageIndex":63},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":59},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":59},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1833920,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8723894160,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095732855128},{"value":0},{"value":6114750272},{"value":6114750288},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7151683628},"cpsr":{"value":1610616832},"fp":{"value":6114750256},"sp":{"value":6114750208},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893476360},"far":{"value":0}}},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":0},{"value":0},{"value":4560112864},{"value":1743},{"value":0},{"value":139531},{"value":18446744073709551615},{"value":4837447816},{"value":4837447816},{"value":5762998320},{"value":4972507624},{"value":2},{"value":589842},{"value":18446744073709551580},{"value":8750560552},{"value":0},{"value":15582208112},{"value":15582208048},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":15130160896},"sp":{"value":15130160880},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":15425439328},{"value":4526991376},{"value":4560112864},{"value":1729382256910270464},{"value":0},{"value":36111},{"value":18446744073709551615},{"value":4828876032},{"value":4828876032},{"value":5762771200},{"value":5091419896},{"value":155904},{"value":669602581471488},{"value":18446744073709551580},{"value":8750560552},{"value":0},{"value":15582206112},{"value":15582206048},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":15130472192},"sp":{"value":15130472176},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":15425448448},{"value":4526991376},{"value":4560112864},{"value":1743},{"value":0},{"value":305675},{"value":18446744073709551615},{"value":4828803576},{"value":4828803576},{"value":15357922432},{"value":5122478000},{"value":155904},{"value":669602581471488},{"value":18446744073709551580},{"value":8750560552},{"value":0},{"value":15582206672},{"value":15582206608},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":15130783488},"sp":{"value":15130783472},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":15425449312},{"value":4526991376},{"value":15131094448},{"value":1729382256910270464},{"value":0},{"value":303579},{"value":18446744073709551615},{"value":4828757872},{"value":4828757872},{"value":17265014752},{"value":5105741872},{"value":1},{"value":4283377034},{"value":18446744073709551580},{"value":8750560552},{"value":0},{"value":15582207232},{"value":15582207168},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7939818512},"cpsr":{"value":1610616832},"fp":{"value":15131094784},"sp":{"value":15131094768},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452880},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"PingThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":2215597534347264},{"value":0},{"value":2215597534347264},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":515859},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8750562800},{"value":0},{"value":4294967295},{"value":2},{"value":2215597534347264},{"value":0},{"value":2215597534347264},{"value":21592279046},{"value":15481904552},{"value":8589934592},{"value":18446744073709550527},{"value":11205083136,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9893466892},"cpsr":{"value":4096},"fp":{"value":15481904400},"sp":{"value":15481904320},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893453012},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":57},{"imageOffset":62204,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":64,"imageIndex":57},{"imageOffset":856440,"symbol":"+[GSDKPing pingThreadEntryPoint:]","symbolLocation":204,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ace_cs2","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":16377802224},{"value":9},{"value":36},{"value":18446726482597246976},{"value":4616695808},{"value":2},{"value":16377802204},{"value":0},{"value":234},{"value":23089744188672},{"value":13824},{"value":59373627913728},{"value":93},{"value":57116606976},{"value":0},{"value":4812364800},{"value":4812365024},{"value":4617035632},{"value":258},{"value":3226763252},{"value":241638085},{"value":134217728},{"value":0},{"value":16377802240},{"value":248706189}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4614711204},"cpsr":{"value":2684358656},"fp":{"value":16377802464},"sp":{"value":16377802224},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893483376},"far":{"value":0}},"frames":[{"imageOffset":33648,"symbol":"__select","symbolLocation":8,"imageIndex":47},{"imageOffset":452516,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15927275520},{"value":879683},{"value":15926738944},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15927275520},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":16259854336},{"value":399395},{"value":16259317760},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":16259854336},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":16162598912},{"value":610475},{"value":16162062336},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":16162598912},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":16173789184},{"value":940095},{"value":16173252608},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":16173789184},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6296612864},{"value":591443},{"value":6296076288},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6296612864},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6300905472},{"value":881699},{"value":6300368896},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6300905472},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"name":"AudioSession - RootQueue","threadState":{"x":[{"value":14},{"value":4294966041869549572},{"value":999999708},{"value":68719460488},{"value":0},{"value":0},{"value":0},{"value":18446726482597246976},{"value":999999708},{"value":3},{"value":13835058055282163714},{"value":80000000},{"value":5228729400},{"value":16668456768},{"value":8723916928,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_os_log"},{"value":8723916928,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_os_log"},{"value":18446744073709551578},{"value":6302248960},{"value":0},{"value":6112034395751},{"value":4820359040},{"value":1000000000},{"value":4820358904},{"value":6302249184},{"value":0},{"value":0},{"value":18446744071411073023},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7940028376},"cpsr":{"value":2147487744},"fp":{"value":6302248768},"sp":{"value":6302248736},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452904},"far":{"value":0}},"frames":[{"imageOffset":3176,"symbol":"semaphore_timedwait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":223192,"symbol":"_dispatch_sema4_timedwait","symbolLocation":64,"imageIndex":51},{"imageOffset":14952,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":76,"imageIndex":51},{"imageOffset":79612,"symbol":"_dispatch_worker_thread","symbolLocation":324,"imageIndex":51},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6308212736},{"value":322063},{"value":6307676160},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6308212736},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6316142592},{"value":987043},{"value":6315606016},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6316142592},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6292467712},{"value":32343},{"value":6291931136},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6292467712},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}},{"id":{{TID}},"name":"AudioSession - RootQueue","threadState":{"x":[{"value":14},{"value":4294967115611373572},{"value":999999958},{"value":68719460488},{"value":16288885248},{"value":0},{"value":0},{"value":0},{"value":999999958},{"value":3},{"value":13835058055282163714},{"value":80000000},{"value":555233185685093017},{"value":555215591351562545},{"value":309248},{"value":4682006528},{"value":18446744073709551578},{"value":8750507488},{"value":0},{"value":6112034395166},{"value":4820359040},{"value":1000000000},{"value":4820358904},{"value":6097547488},{"value":0},{"value":0},{"value":18446744071411073023},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7940028376},"cpsr":{"value":2147487744},"fp":{"value":6097547072},"sp":{"value":6097547040},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9893452904},"far":{"value":0}},"frames":[{"imageOffset":3176,"symbol":"semaphore_timedwait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":223192,"symbol":"_dispatch_sema4_timedwait","symbolLocation":64,"imageIndex":51},{"imageOffset":14952,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":76,"imageIndex":51},{"imageOffset":79612,"symbol":"_dispatch_worker_thread","symbolLocation":324,"imageIndex":51},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6102708224},{"value":84743},{"value":6102171648},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6102708224},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8558258360},"far":{"value":0}}}],
  "usedImages" : [
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4369891328}},
    "size" : 204603392,
    "uuid" : "{{SLICE_UUID}}",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/cod",
    "name" : "cod"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4610883584}},
    "size" : 1687552,
    "uuid" : "789e17cd-d13f-35d6-97d9-00eb01699395",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/LineSDK.framework\/LineSDK",
    "name" : "LineSDK"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4608933888}},
    "size" : 65536,
    "uuid" : "042997a5-1601-37e0-92d9-5304f4c81262",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAgeRange.framework\/MSDKPIXAgeRange",
    "name" : "MSDKPIXAgeRange"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4613292032}},
    "size" : 344064,
    "uuid" : "ba9f446f-4357-3638-8b1c-420329ab4ec7",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKLoginKit.framework\/FBSDKLoginKit",
    "name" : "FBSDKLoginKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4614258688}},
    "size" : 2719744,
    "uuid" : "012c9348-ff37-38ec-8089-07fdf5e10a07",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/anogs.framework\/anogs",
    "name" : "anogs"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4617306112}},
    "size" : 311296,
    "uuid" : "ed95e02a-12fd-36d3-8149-e39652bae555",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/HelpshiftX.framework\/HelpshiftX",
    "name" : "HelpshiftX"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4617961472}},
    "size" : 344064,
    "uuid" : "0e1ddd7d-b20d-39d3-a484-7b03f479cb53",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKGamingServicesKit.framework\/FBSDKGamingServicesKit",
    "name" : "FBSDKGamingServicesKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4609114112}},
    "size" : 81920,
    "uuid" : "eaea1a4b-7f7b-3b62-a16d-9f5225ea1063",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXGameCenter.framework\/MSDKPIXGameCenter",
    "name" : "MSDKPIXGameCenter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4609343488}},
    "size" : 65536,
    "uuid" : "a052368f-a3a1-3af5-a773-28a4fe12196b",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXUNO.framework\/MSDKPIXUNO",
    "name" : "MSDKPIXUNO"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4610228224}},
    "size" : 49152,
    "uuid" : "77485837-124f-3fe6-9987-99f919fe5909",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXSystem.framework\/MSDKPIXSystem",
    "name" : "MSDKPIXSystem"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4619124736}},
    "size" : 507904,
    "uuid" : "86a4f6d1-63b5-33b3-a714-c7dcfe786011",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/TDataMaster.framework\/TDataMaster",
    "name" : "TDataMaster"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4620091392}},
    "size" : 32768,
    "uuid" : "25026fbe-1e50-3483-8da1-2ad9b09c31df",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightAdapter.framework\/CrashSightAdapter",
    "name" : "CrashSightAdapter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4620189696}},
    "size" : 1245184,
    "uuid" : "4b4cdcfa-144a-33ca-a98f-038c56bdfa67",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GPM_dylib.framework\/GPM_dylib",
    "name" : "GPM_dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4622467072}},
    "size" : 49152,
    "uuid" : "2086552d-0049-3675-9d7e-0d2e17b5b884",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXApple.framework\/MSDKPIXApple",
    "name" : "MSDKPIXApple"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4610375680}},
    "size" : 32768,
    "uuid" : "e564426d-cabd-3e48-b7b0-9a1603ae2f81",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/TDMASA.framework\/TDMASA",
    "name" : "TDMASA"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4622598144}},
    "size" : 32768,
    "uuid" : "dc00db9a-27ab-3bb3-8bad-bb2b26c4b824",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/videotexture.framework\/videotexture",
    "name" : "videotexture"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4622680064}},
    "size" : 344064,
    "uuid" : "c72576aa-6c65-33c6-a0a2-7577ae6e836d",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXWebView.framework\/MSDKPIXWebView",
    "name" : "MSDKPIXWebView"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4623335424}},
    "size" : 688128,
    "uuid" : "e3c82398-46d1-388a-96f3-98a3d93ca328",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GCloudCore.framework\/GCloudCore",
    "name" : "GCloudCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4624662528}},
    "size" : 245760,
    "uuid" : "ac9592c9-aa67-35fb-9e23-9f3ede984913",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBAEMKit.framework\/FBAEMKit",
    "name" : "FBAEMKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4625285120}},
    "size" : 1277952,
    "uuid" : "20ab51da-9e05-37f4-9919-1147ae5b5fbd",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXCore.framework\/MSDKPIXCore",
    "name" : "MSDKPIXCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4628905984}},
    "size" : 65536,
    "uuid" : "5cebc6ee-3bdc-3d61-a494-a9db5609d7d5",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXLine.framework\/MSDKPIXLine",
    "name" : "MSDKPIXLine"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4629102592}},
    "size" : 1015808,
    "uuid" : "a173f8f8-e72b-3686-b77d-9aa011d69110",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSight.framework\/CrashSight",
    "name" : "CrashSight"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4631150592}},
    "size" : 5963776,
    "uuid" : "47279944-76a8-3a9e-8155-1f1a69996ee3",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PxKit3.framework\/PxKit3",
    "name" : "PxKit3"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4639457280}},
    "size" : 32768,
    "uuid" : "a8405d09-048c-3b1a-9ec9-1ba91d9a3183",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PluginCrosCurl.framework\/PluginCrosCurl",
    "name" : "PluginCrosCurl"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4639555584}},
    "size" : 32768,
    "uuid" : "9ce39a89-e5e9-3abc-a49b-d0714d031401",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GPixUI.framework\/GPixUI",
    "name" : "GPixUI"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4639653888}},
    "size" : 2064384,
    "uuid" : "2bac3286-cc10-3faa-bb02-6f84a3d39864",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/LineSDKObjC.framework\/LineSDKObjC",
    "name" : "LineSDKObjC"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4642668544}},
    "size" : 163840,
    "uuid" : "8cee3d3a-f704-3985-8559-646260d61f15",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAdapter.framework\/MSDKPIXAdapter",
    "name" : "MSDKPIXAdapter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4643078144}},
    "size" : 32768,
    "uuid" : "acc1ad31-235e-39c2-bc83-3fe3909fc52e",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXTDM.framework\/MSDKPIXTDM",
    "name" : "MSDKPIXTDM"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4643176448}},
    "size" : 32768,
    "uuid" : "9171c5c3-bc6e-36ec-aeb4-f67e52af26e2",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPolicy.framework\/MSDKPolicy",
    "name" : "MSDKPolicy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4643258368}},
    "size" : 49152,
    "uuid" : "53387f9f-2ca5-3522-80b9-534de9c18a84",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAppsFlyer.framework\/MSDKPIXAppsFlyer",
    "name" : "MSDKPIXAppsFlyer"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4643454976}},
    "size" : 1245184,
    "uuid" : "7e56c197-9bc6-3bc0-97b8-e87abaabd89c",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKCoreKit.framework\/FBSDKCoreKit",
    "name" : "FBSDKCoreKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4646862848}},
    "size" : 278528,
    "uuid" : "5cb7f8ab-b746-3481-8a0b-bc2738410394",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKShareKit.framework\/FBSDKShareKit",
    "name" : "FBSDKShareKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4647682048}},
    "size" : 17891328,
    "uuid" : "36a4c1de-f7c2-3210-8c64-05a2ad6353ea",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GCloud.framework\/GCloud",
    "name" : "GCloud"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4666638336}},
    "size" : 393216,
    "uuid" : "88e748d7-46a0-33aa-aa43-31d045548ac3",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/enq_transceiver_dy.framework\/enq_transceiver_dy",
    "name" : "enq_transceiver_dy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4667342848}},
    "size" : 49152,
    "uuid" : "5b47ada5-3e79-3ccb-88b3-009df3fb7295",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightPlugin.framework\/CrashSightPlugin",
    "name" : "CrashSightPlugin"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4667473920}},
    "size" : 32768,
    "uuid" : "b5c35e91-a5ae-3419-afd5-a11b6d68d364",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/APMDeviceInfoSupport_dylib.framework\/APMDeviceInfoSupport_dylib",
    "name" : "APMDeviceInfoSupport_dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4667555840}},
    "size" : 442368,
    "uuid" : "7548dc41-8466-332b-ab3a-3facf7b2a30a",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PxEmbedded.framework\/PxEmbedded",
    "name" : "PxEmbedded"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4669227008}},
    "size" : 81920,
    "uuid" : "21471420-b035-3be4-ab03-dd3d65378d9d",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXFacebook.framework\/MSDKPIXFacebook",
    "name" : "MSDKPIXFacebook"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4669489152}},
    "size" : 409600,
    "uuid" : "b2dbfcaf-c010-3f32-b3fa-7622cab07a78",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/crosCurl.framework\/crosCurl",
    "name" : "crosCurl"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4670013440}},
    "size" : 147456,
    "uuid" : "f042e662-c341-3f44-b6f4-36ed32655f31",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPopup.framework\/MSDKPopup",
    "name" : "MSDKPopup"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4670291968}},
    "size" : 3686400,
    "uuid" : "d1db61c9-0b90-3667-8f4c-1ddb0b80514f",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PixVideo.framework\/PixVideo",
    "name" : "PixVideo"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4676698112}},
    "size" : 32768,
    "uuid" : "a96d62b0-46ed-3b75-9445-608678ed8336",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXSensitivity.framework\/MSDKPIXSensitivity",
    "name" : "MSDKPIXSensitivity"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4676780032}},
    "size" : 425984,
    "uuid" : "2e2fc0e2-16ac-3955-af09-cc66a0e34d39",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/AppsFlyerLib.framework\/AppsFlyerLib",
    "name" : "AppsFlyerLib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4677681152}},
    "size" : 98304,
    "uuid" : "d41c7c18-e896-3e8d-b978-73bed639f192",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightCore.framework\/CrashSightCore",
    "name" : "CrashSightCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4677943296}},
    "size" : 753664,
    "uuid" : "167bff7e-e558-3007-8424-0c95998ca46b",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/kgvmp_dy.framework\/kgvmp_dy",
    "name" : "kgvmp_dy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4679204864}},
    "size" : 65536,
    "uuid" : "6ed9543d-d000-3c65-a476-da0b5450fce2",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKCoreKit_Basics.framework\/FBSDKCoreKit_Basics",
    "name" : "FBSDKCoreKit_Basics"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:4804804608}},
    "size" : 49152,
    "uuid" : "004ce93c-f142-3d68-b3c3-30c6efef4d65",
    "path" : "\/private\/preboot\/Cryptexes\/OS\/usr\/lib\/libobjc-trampolines.dylib",
    "name" : "libobjc-trampolines.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:9893449728}},
    "size" : 244512,
    "uuid" : "18665b3f-6d51-33ab-b9e9-63062200ec42",
    "path" : "\/usr\/lib\/system\/libsystem_kernel.dylib",
    "name" : "libsystem_kernel.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:8558256128}},
    "size" : 50416,
    "uuid" : "34b44744-bc64-386e-ab90-eee86b23ac46",
    "path" : "\/usr\/lib\/system\/libsystem_pthread.dylib",
    "name" : "libsystem_pthread.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7051771904}},
    "size" : 39073344,
    "uuid" : "0d94422f-fe7c-302e-b896-3bc5873c0cfc",
    "path" : "\/System\/Library\/PrivateFrameworks\/UIKitCore.framework\/UIKitCore",
    "name" : "UIKitCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7511126016}},
    "size" : 929920,
    "uuid" : "cdb80f7a-3de2-32f4-9a09-7de06100970c",
    "path" : "\/System\/Library\/PrivateFrameworks\/FrontBoardServices.framework\/FrontBoardServices",
    "name" : "FrontBoardServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7939805184}},
    "size" : 288256,
    "uuid" : "49c0cd3e-a696-3b11-ba92-5755f0c3c6e3",
    "path" : "\/usr\/lib\/system\/libdispatch.dylib",
    "name" : "libdispatch.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7363657728}},
    "size" : 544096,
    "uuid" : "2fe35d43-52cf-3d5a-bfbf-04b3943c4af1",
    "path" : "\/System\/Library\/PrivateFrameworks\/BoardServices.framework\/BoardServices",
    "name" : "BoardServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6955036672}},
    "size" : 5884480,
    "uuid" : "101eb2f1-1915-34a0-8bc9-631d03753b84",
    "path" : "\/System\/Library\/Frameworks\/CoreFoundation.framework\/CoreFoundation",
    "name" : "CoreFoundation"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:9735700480}},
    "size" : 34752,
    "uuid" : "411165e2-ee8e-380e-b254-9977273971e3",
    "path" : "\/System\/Library\/PrivateFrameworks\/GraphicsServices.framework\/GraphicsServices",
    "name" : "GraphicsServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6900731904}},
    "size" : 676992,
    "uuid" : "0f8d35b6-556f-3e34-8eaa-80ab54047dc5",
    "path" : "\/usr\/lib\/dyld",
    "name" : "dyld"
  },
  {
    "size" : 0,
    "source" : "A",
    "base" : {{IMG_BASE:0}},
    "uuid" : "00000000-0000-0000-0000-000000000000"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6907396096}},
    "size" : 15244480,
    "uuid" : "73841aa3-bfdd-322d-8dc2-e5185a14dee1",
    "path" : "\/System\/Library\/Frameworks\/Foundation.framework\/Foundation",
    "name" : "Foundation"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:8588414976}},
    "size" : 2858528,
    "uuid" : "f33d86e4-aa3b-3d38-b82a-f4226d3ed07e",
    "path" : "\/System\/Library\/PrivateFrameworks\/CoreWiFi.framework\/CoreWiFi",
    "name" : "CoreWiFi"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7151632384}},
    "size" : 521728,
    "uuid" : "ff429821-80de-3a68-99cb-0b2e707e8d48",
    "path" : "\/usr\/lib\/system\/libsystem_c.dylib",
    "name" : "libsystem_c.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7312261120}},
    "size" : 3868544,
    "uuid" : "3ae849fe-8a7d-388c-86ef-64dedb9fc5c6",
    "path" : "\/System\/Library\/Frameworks\/CFNetwork.framework\/CFNetwork",
    "name" : "CFNetwork"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7375691776}},
    "size" : 4551488,
    "uuid" : "33533ca9-f9fb-3516-af0a-03c1b9469f97",
    "path" : "\/System\/Library\/Frameworks\/CoreMotion.framework\/CoreMotion",
    "name" : "CoreMotion"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:11681460224}},
    "size" : 167968,
    "uuid" : "5dd354fb-a86f-3732-8f36-a88736414f79",
    "path" : "\/System\/Library\/PrivateFrameworks\/caulk.framework\/caulk",
    "name" : "caulk"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7316131840}},
    "size" : 32251488,
    "uuid" : "f7906028-1c6d-3b4c-bd93-78c196c83a83",
    "path" : "\/System\/Library\/Frameworks\/JavaScriptCore.framework\/JavaScriptCore",
    "name" : "JavaScriptCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7411228672}},
    "size" : 24644064,
    "uuid" : "c39bd22c-3475-38af-91bd-0b7574081011",
    "path" : "\/System\/Library\/Frameworks\/WebKit.framework\/WebKit",
    "name" : "WebKit"
  }
],
  "sharedCache" : {
  "base" : {{IMG_BASE:6899564544}},
  "size" : 5383520256,
  "uuid" : "a0faea75-70ff-3a53-8881-bc6fe2b6c70b"
},
  "vmSummary" : "ReadOnly portion of Libraries: Total=2.3G resident=0K(0%) swapped_out_or_unallocated=2.3G(100%)\nWritable regions: Total=4.8G written=2714K(0%) resident=2618K(0%) swapped_out=128K(0%) unallocated=4.8G(100%)\n\n                                VIRTUAL   REGION \nREGION TYPE                        SIZE    COUNT (non-coalesced) \n===========                     =======  ======= \nActivity Tracing                   256K        1 \nAttributeGraph Data               1024K        1 \nAudio                               64K        1 \nCG raster data                     160K        3 \nColorSync                           16K        1 \nCoreAnimation                      272K       12 \nFoundation                         208K        2 \nImage IO                          4112K        2 \nJS VM Gigacage (reserved)          2.0G        1         reserved VM address space (unallocated)\nKernel Alloc Once                   32K        1 \nMALLOC                             1.6G      425 \nMALLOC guard page                 4112K        4 \nMach message                      5232K      327 \nMemory Tag 22                     64.0M        1 \nSQLite page cache                 1280K       10 \nSTACK GUARD                        848K       53 \nStack                             27.6M       53 \nVM_ALLOCATE                      877.2M    10296 \nVM_ALLOCATE (media)               10.0M        1 \nVM_ALLOCATE (reserved)             560K        7         reserved VM address space (unallocated)\nWebKit Malloc                    256.1M        8 \n__AUTH                            12.0M      982 \n__AUTH_CONST                     127.0M     1431 \n__CTF                               824        1 \n__DATA                            79.3M     1431 \n__DATA_CONST                      54.0M     1444 \n__DATA_DIRTY                      12.3M     1248 \n__FONT_DATA                        2352        1 \n__LINKEDIT                       203.3M       48 \n__OBJC_RO                         84.8M        1 \n__OBJC_RW                         3182K        1 \n__TEXT                             2.1G     1503 \n__TPRO_CONST                       128K        2 \ndyld private memory                128K        1 \nmapped file                      394.2M      183 \npage table in kernel              2618K        1 \nshared memory                       80K        4 \n===========                     =======  ======= \nTOTAL                              7.9G    19492 \nTOTAL, minus reserved VM space     5.9G    19492 \n",
  "legacyInfo" : {
  "threadTriggered" : {
    "queue" : "com.apple.main-thread"
  }
},
  "logWritingSignature" : "{{LOG_SIGNATURE}}",
  "roots_installed" : 0,
  "bug_type" : "309",
  "trmStatus" : 1,
  "sandboxProfileName" : "container",
  "voucherInfos" : [{"originatorName":"SpringBoard","proximateName":"SpringBoard","thread_id":1489351}],
  "trialInfo" : {
  "rollouts" : [
    {
      "rolloutId" : "6434420a89ec2e0a7a38bf5a",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000011
    },
    {
      "rolloutId" : "64628732bf2f5257dedc8988",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000001
    }
  ],
  "experiments" : [
    {
      "treatmentId" : "d5c127b8-b13e-42a1-acf5-c483124a1bb5",
      "experimentId" : "66b1602abe27b2208fd291ba",
      "deploymentId" : 400000022
    },
    {
      "treatmentId" : "582596be-1d4a-408d-901b-5b311c006a4a",
      "experimentId" : "65f31ccb74b6f500a45abda4",
      "deploymentId" : 400000026
    }
  ]
}
}

"""#

    /// 56 threads, 65 loaded images.
    static let templateB = #"""
{"app_name":"cod","timestamp":"{{TIMESTAMP}}","app_version":"{{APP_VERSION}}","slice_uuid":"{{SLICE_UUID}}","adam_id":"1287282214","build_version":"{{APP_BUILD}}","bundleID":"com.activision.callofduty.shooter","platform":2,"share_with_app_devs":1,"is_first_party":0,"bug_type":"309","os_version":"{{OS_VERSION_FULL}}","roots_installed":0,"incident_id":"{{INCIDENT}}","name":"cod"}
{
  "uptime" : {{UPTIME}},
  "procRole" : "Non UI",
  "version" : 2,
  "userID" : 501,
  "deployVersion" : 210,
  "modelCode" : "{{MODEL_CODE}}",
  "coalitionID" : {{COALITION_ID}},
  "osVersion" : {
    "isEmbedded" : true,
    "train" : "{{OS_TRAIN}}",
    "releaseType" : "User",
    "build" : "{{OS_BUILD}}"
  },
  "captureTime" : "{{CAPTURE_TIME}}",
  "codeSigningMonitor" : 1,
  "incident" : "{{INCIDENT}}",
  "pid" : {{PID}},
  "translated" : false,
  "cpuType" : "ARM-64",
  "procLaunch" : "{{PROC_LAUNCH}}",
  "procStartAbsTime" : {{PROC_START_ABS}},
  "procExitAbsTime" : {{PROC_EXIT_ABS}},
  "procName" : "cod",
  "procPath" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/cod",
  "bundleInfo" : {"CFBundleShortVersionString":"{{APP_VERSION}}","CFBundleVersion":"{{APP_BUILD}}","CFBundleIdentifier":"com.activision.callofduty.shooter","DTAppStoreToolsBuild":"17F106"},
  "storeInfo" : {"itemID":"1287282214","storeCohortMetadata":"{{STORE_COHORT}}","distributorID":"com.apple.AppStore","deviceIdentifierForVendor":"{{IDFV}}","softwareVersionExternalIdentifier":"{{SW_EXT_ID}}","applicationVariant":"1:{{MODEL_CODE}}:18","thirdParty":true},
  "parentProc" : "launchd",
  "parentPid" : 1,
  "coalitionName" : "com.activision.callofduty.shooter",
  "crashReporterKey" : "{{CRASH_REPORTER_KEY}}",
  "appleIntelligenceStatus" : {"state":"available"},
  "bootProgressRegister" : "0x20800004",
  "wasUnlockedSinceBoot" : 1,
  "isLocked" : 0,
  "codeSigningID" : "com.activision.callofduty.shooter",
  "codeSigningTeamID" : "6KZFBJ4CBY",
  "codeSigningFlags" : 570450689,
  "codeSigningValidationCategory" : 4,
  "codeSigningTrustLevel" : 7,
  "codeSigningAuxiliaryInfo" : 0,
  "instructionByteStream" : {"beforePC":"fyMD1f17v6n9AwCRuwAAlL8DAJH9e8Go\/w9f1sADX9YwJoDSARAA1A==","atPC":"AwEAVH8jA9X9e7+p\/QMAkcIAAJS\/AwCR\/XvBqP8PX9bAA1\/WkCqA0g=="},
  "bootSessionUUID" : "{{BOOT_SESSION}}",
  "exception" : {"codes":"0x0000000000000000, 0x0000000000000000","rawCodes":[0,0],"type":"EXC_CRASH","signal":"SIGKILL"},
  "termination" : {"code":2343432205,"flags":6,"namespace":"FRONTBOARD","reasons":["<RBSTerminateContext| domain:10 code:0x8BADF00D explanation:[app<com.activision.callofduty.shooter>:{{PID}}] Failed to terminate gracefully after 5.0s","ProcessVisibility: Unknown","ProcessState: Running","WatchdogEvent: process-exit","WatchdogVisibility: Foreground","WatchdogCPUStatistics: (","\"Elapsed total CPU time (seconds): {{CPU_TOTAL}} (user {{CPU_USER}}, system {{CPU_SYS}}), {{CPU_PCT}}% CPU\",","\"Elapsed application CPU time (seconds): {{CPU_APP}}, {{CPU_APP_PCT}}% CPU\"",")","ThermalInfo: (","\"Thermal Level:   0\",","\"Thermal State:   nominal\"",") reportType:CrashLog maxTerminationResistance:Interactive>"]},
  "faultingThread" : 0,
  "threads" : [{"triggered":true,"id":{{TID}},"threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6156787336},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":8664818112,"symbolLocation":0,"symbol":"_main_thread"},{"value":0},{"value":6441496840},{"value":6441496904},{"value":8664818336,"symbolLocation":224,"symbol":"_main_thread"},{"value":0},{"value":0},{"value":0},{"value":1},{"value":256},{"value":3777893186295716171},{"value":4294967295}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6156787456},"sp":{"value":6156787312},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576,"matchesCrashFrame":1},"far":{"value":0}},"queue":"com.apple.main-thread","frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":154559212,"imageIndex":0},{"imageOffset":154542520,"imageIndex":0},{"imageOffset":154937848,"imageIndex":0},{"imageOffset":154910068,"imageIndex":0},{"imageOffset":163598636,"imageIndex":0},{"imageOffset":164208132,"imageIndex":0},{"imageOffset":96144,"imageIndex":0},{"imageOffset":446724,"symbol":"-[GCloudAppLifecycleDispatcher gcloud_applicationWillTerminate:]","symbolLocation":108,"imageIndex":17},{"imageOffset":23072064,"symbol":"-[UIApplication _terminateWithStatus:]","symbolLocation":196,"imageIndex":49},{"imageOffset":1670180,"symbol":"-[_UISceneLifecycleMultiplexer _evalTransitionToSettings:fromSettings:forceExit:withTransitionStore:]","symbolLocation":108,"imageIndex":49},{"imageOffset":14273860,"symbol":"-[_UISceneLifecycleMultiplexer forceExitWithTransitionContext:scene:]","symbolLocation":156,"imageIndex":49},{"imageOffset":23060408,"symbol":"-[UIApplication workspaceShouldExit:withTransitionContext:]","symbolLocation":180,"imageIndex":49},{"imageOffset":368636,"symbol":"__63-[FBSWorkspaceScenesClient willTerminateWithTransitionContext:]_block_invoke","symbolLocation":76,"imageIndex":50},{"imageOffset":148768,"symbol":"-[FBSWorkspace _calloutQueue_executeCalloutFromSource:withBlock:]","symbolLocation":176,"imageIndex":50},{"imageOffset":111076,"symbol":"_dispatch_client_callout","symbolLocation":16,"imageIndex":51},{"imageOffset":26260,"symbol":"_dispatch_block_invoke_direct","symbolLocation":284,"imageIndex":51},{"imageOffset":180100,"symbol":"__BSSERVICEMAINRUNLOOPQUEUE_IS_CALLING_OUT_TO_A_BLOCK__","symbolLocation":52,"imageIndex":52},{"imageOffset":179712,"symbol":"BSServiceMainRunLoopSourceHandler","symbolLocation":224,"imageIndex":52},{"imageOffset":656272,"symbol":"__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__","symbolLocation":28,"imageIndex":53},{"imageOffset":656132,"symbol":"__CFRunLoopDoSource0","symbolLocation":172,"imageIndex":53},{"imageOffset":415292,"symbol":"__CFRunLoopDoSources0","symbolLocation":332,"imageIndex":53},{"imageOffset":192928,"symbol":"__CFRunLoopRun","symbolLocation":820,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":5272,"symbol":"GSEventRunModal","symbolLocation":120,"imageIndex":54},{"imageOffset":1185392,"symbol":"-[UIApplication _run]","symbolLocation":796,"imageIndex":49},{"imageOffset":573784,"symbol":"UIApplicationMain","symbolLocation":332,"imageIndex":49},{"imageOffset":16592,"imageIndex":0},{"imageOffset":19484,"symbol":"start","symbolLocation":6928,"imageIndex":55}]},{"id":{{TID}},"name":"com.apple.uikit.eventfetch-thread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":60486024429568},{"value":0},{"value":60486024429568},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":14083},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":60486024429568},{"value":0},{"value":60486024429568},{"value":21592279046},{"value":6159637896},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6159637744},"sp":{"value":6159637664},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":57},{"imageOffset":43992,"symbol":"-[NSRunLoop(NSRunLoop) runUntilDate:]","symbolLocation":64,"imageIndex":57},{"imageOffset":945836,"symbol":"-[UIEventFetcher threadMain]","symbolLocation":420,"imageIndex":49},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"TDM-report-1","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":6161362640},{"value":6161362656},{"value":3435973837},{"value":2},{"value":1374389535},{"value":50},{"value":0},{"value":1},{"value":1},{"value":40264}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6161362624},"sp":{"value":6161362576},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":206100,"symbol":"TDM::TDataMasterReporter::LoopReportData()","symbolLocation":392,"imageIndex":10},{"imageOffset":205056,"symbol":"TDM::TDataMasterReporter::ProcessSingleThread(void*)","symbolLocation":64,"imageIndex":10},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":58},{"imageOffset":134980,"symbol":"MSDKScriptVM_LoadVMWithCallback","symbolLocation":648,"imageIndex":19},{"imageOffset":747976,"symbol":"initPixVM(void*)","symbolLocation":148,"imageIndex":19},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":18446744072631617535},{"value":18446726482597246976},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":15},{"value":2607872},{"value":5168335296},{"value":8664839424,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSArray0"},{"value":8664839424,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSArray0"},{"value":334},{"value":6896055000,"symbolLocation":0,"symbol":"-[__NSArray0 release]"},{"value":0},{"value":0},{"value":6161935728},{"value":4566839296,"symbolLocation":16,"symbol":"msdk_puerts::ClassDefineBuilder<JSLoggerInterface> msdk_puerts::DefineClass<JSLoggerInterface>()::NameLiteral"},{"value":1},{"value":2},{"value":8694774600,"symbolLocation":0,"symbol":"__NSArray0__struct"},{"value":8903361176,"objc-selector":"countByEnumeratingWithState:objects:count:"},{"value":0},{"value":4566567388},{"value":4566839296,"symbolLocation":16,"symbol":"msdk_puerts::ClassDefineBuilder<JSLoggerInterface> msdk_puerts::DefineClass<JSLoggerInterface>()::NameLiteral"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6161935712},"sp":{"value":6161935664},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"OperationQueue.ThreadProcess","threadState":{"x":[{"value":4},{"value":0},{"value":256},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6162509512},{"value":0},{"value":512},{"value":2199023256066},{"value":2199023256066},{"value":512},{"value":0},{"value":2199023256064},{"value":305},{"value":4729061095673708888},{"value":0},{"value":4705226072},{"value":4705226136},{"value":6162510048},{"value":0},{"value":0},{"value":256},{"value":256},{"value":768},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6162509632},"sp":{"value":6162509488},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":215812,"symbol":"ABase::CCondition::Wait()","symbolLocation":52,"imageIndex":17},{"imageOffset":215276,"symbol":"ABase::OperationQueueImp::onThreadProc(void*)","symbolLocation":348,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"OperationQueue.ThreadProcess","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6163082952},{"value":0},{"value":512},{"value":2199023256066},{"value":2199023256066},{"value":512},{"value":0},{"value":2199023256064},{"value":305},{"value":4729061095673708888},{"value":0},{"value":4705226072},{"value":4705226136},{"value":6163083488},{"value":0},{"value":0},{"value":256},{"value":257},{"value":512},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6163083072},"sp":{"value":6163082928},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":215812,"symbol":"ABase::CCondition::Wait()","symbolLocation":52,"imageIndex":17},{"imageOffset":215276,"symbol":"ABase::OperationQueueImp::onThreadProc(void*)","symbolLocation":348,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"OperationQueue.ThreadManager","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":0},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":512},{"value":0},{"value":512},{"value":2199023256064},{"value":334},{"value":4729061095673708888},{"value":0},{"value":0},{"value":6163656512},{"value":4705226136},{"value":4705226024},{"value":0},{"value":4754653424},{"value":0},{"value":4564234240,"symbolLocation":56,"symbol":"vtable for ABase::_tagApolloActionBufferBase"},{"value":10},{"value":1788617263565}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6163656496},"sp":{"value":6163656448},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":215672,"symbol":"ABase::SleepMS(long long)","symbolLocation":80,"imageIndex":17},{"imageOffset":214752,"symbol":"ABase::OperationQueueImp::onThreadManageProc(void*)","symbolLocation":428,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"XLogThread","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":65704},{"value":86399},{"value":999999000},{"value":6170537624},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":2},{"value":0},{"value":4755870976},{"value":4755871104},{"value":6170538208},{"value":999999000},{"value":86399},{"value":0},{"value":1},{"value":256},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6170537744},"sp":{"value":6170537600},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":187356,"symbol":"ABase::CCondition::TimeWait(unsigned int)","symbolLocation":172,"imageIndex":17},{"imageOffset":184984,"symbol":"ABase::Logger::_XLogThread(void*)","symbolLocation":60,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"CThreadBase","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":438796742555104164},{"value":24000000},{"value":570906},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":0},{"value":6164803344},{"value":4754816320},{"value":4754816248},{"value":4754816392},{"value":4564056094,"symbolLocation":25336,"symbol":"ABase::base64_chars2"},{"value":4564045871,"symbolLocation":15113,"symbol":"ABase::base64_chars2"},{"value":1},{"value":4564056726,"symbolLocation":25968,"symbol":"ABase::base64_chars2"},{"value":4564056818,"symbolLocation":26060,"symbol":"ABase::base64_chars2"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6164803328},"sp":{"value":6164803280},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":285468,"symbol":"ABase::CThreadBase::Sleep(int)","symbolLocation":84,"imageIndex":17},{"imageOffset":233208,"symbol":"ABase::CTimerImp::OnThreadProc()","symbolLocation":168,"imageIndex":17},{"imageOffset":284812,"symbol":"ABase::CThreadBase::onThreadProc(void*)","symbolLocation":704,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GC Finalizer","threadState":{"x":[{"value":260},{"value":0},{"value":176128},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6167096888},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":68169720938240},{"value":0},{"value":4704101608},{"value":4704101672},{"value":6167097568},{"value":0},{"value":0},{"value":176128},{"value":176129},{"value":176384},{"value":3777893186295716171},{"value":4294967295}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6167097008},"sp":{"value":6167096864},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":154559212,"imageIndex":0},{"imageOffset":154301356,"imageIndex":0},{"imageOffset":154542320,"imageIndex":0},{"imageOffset":154569268,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"Loading.AsyncRead","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":4750409744},{"value":0},{"value":4500311264},{"value":574},{"value":574},{"value":41219},{"value":18446744073709551615},{"value":21836300932715522},{"value":4294967293},{"value":5084160},{"value":0},{"value":5084160},{"value":21836300932715520},{"value":18446744073709551580},{"value":33004810560},{"value":0},{"value":4842440000},{"value":4842439936},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6168243920},"sp":{"value":6168243904},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":158991972,"imageIndex":0},{"imageOffset":158990420,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"com.apple.NSURLConnectionLoader","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":370548303462400},{"value":0},{"value":370548303462400},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":86275},{"value":148992},{"value":639915767514624},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":370548303462400},{"value":0},{"value":370548303462400},{"value":21592279046},{"value":6179134792},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6179134640},"sp":{"value":6179134560},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":596820,"symbol":"+[__CFN_CoreSchedulingSetRunnable _run:]","symbolLocation":416,"imageIndex":59},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"UnityGfxDeviceWorker","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":68719460488},{"value":16271240256},{"value":0},{"value":0},{"value":0},{"value":83203},{"value":18446744073709551615},{"value":1113312},{"value":0},{"value":531744750689065662},{"value":531727156355535358},{"value":6144},{"value":4621729792},{"value":18446744073709551580},{"value":26058195454},{"value":0},{"value":5171483072},{"value":5171483008},{"value":18446744073709551615},{"value":4841152004},{"value":2634130947008},{"value":10000},{"value":1113312},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6160788352},"sp":{"value":6160788336},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":162637164,"imageIndex":0},{"imageOffset":159317192,"imageIndex":0},{"imageOffset":164673120,"imageIndex":0},{"imageOffset":159350252,"imageIndex":0},{"imageOffset":159316944,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"com.apple.CoreMotion.MotionThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":404633163923456},{"value":0},{"value":404633163923456},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":94211},{"value":11264},{"value":48378511633408},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":404633163923456},{"value":0},{"value":404633163923456},{"value":21592279046},{"value":6166518040},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6166517888},"sp":{"value":6166517808},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":912868,"symbol":"CFRunLoopRun","symbolLocation":64,"imageIndex":53},{"imageOffset":91516,"imageIndex":60},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"mgpa_handler","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":536574559256576},{"value":0},{"value":536574559256576},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":124931},{"value":1536},{"value":6597069768192},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":536574559256576},{"value":0},{"value":536574559256576},{"value":21592279046},{"value":6171680152},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6171680000},"sp":{"value":6171679920},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":57},{"imageOffset":62204,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":64,"imageIndex":57},{"imageOffset":27520,"symbol":"-[MGPAMsgServer startMainHandlerRunloop]","symbolLocation":244,"imageIndex":44},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"APM-IOS-WorkThread","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":63},{"value":2607872},{"value":5677559280},{"value":72057602702767201,"symbolLocation":72057594037927937,"symbol":"OBJC_CLASS_$___NSCFString"},{"value":8664839264,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSCFString"},{"value":334},{"value":6895959556,"symbolLocation":0,"symbol":"-[__NSCFString release]"},{"value":0},{"value":6172256048},{"value":6172256064},{"value":4561432019},{"value":8903882648,"objc-selector":"sharedManager"},{"value":4561432062},{"value":4561432338},{"value":4705084416},{"value":8889338136,"objc-selector":"sharedInstance"},{"value":38848},{"value":4561432216}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6172256032},"sp":{"value":6172255984},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":193144,"symbol":"-[TApmApiSingleInstance startWorkThread]","symbolLocation":2784,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"APM-IOS-UploadThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":96},{"value":18446726483666796544},{"value":16074956800},{"value":6172825960},{"value":6172825956},{"value":6172825944},{"value":100099},{"value":18446744073709551615},{"value":0},{"value":0},{"value":2762855826904367608},{"value":2762838232570837760},{"value":49152},{"value":4621729792},{"value":18446744073709551580},{"value":23507747584},{"value":0},{"value":5169960640},{"value":5169960576},{"value":18446744073709551615},{"value":8889338136,"objc-selector":"sharedInstance"},{"value":4561411135},{"value":4561418481},{"value":4561418550},{"value":16074955904},{"value":16074955904},{"value":5129662560}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6172830800},"sp":{"value":6172830784},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":196656,"symbol":"-[TApmApiSingleInstance startUploadThread]","symbolLocation":132,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ace_schedule3","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":6176271984},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":4555373216},{"value":14522130158869348561},{"value":6},{"value":3998368724},{"value":24000000},{"value":53318},{"value":5888},{"value":25288767444736},{"value":93},{"value":8691413816},{"value":0},{"value":5131810240},{"value":0},{"value":1},{"value":0},{"value":3266728883},{"value":2756327217},{"value":4557634624},{"value":2032324052},{"value":342936582},{"value":38274408}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4555400368},"cpsr":{"value":2684358656},"fp":{"value":6176272096},"sp":{"value":6176271840},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834337136},"far":{"value":0}},"frames":[{"imageOffset":33648,"symbol":"__select","symbolLocation":8,"imageIndex":47},{"imageOffset":550064,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1439664,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":60},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":8691414312},{"value":0},{"value":6177419024},{"value":6177419040},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6177419008},"sp":{"value":6177418960},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1617124,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":768},{"value":0},{"value":768},{"value":3298534884096},{"value":334},{"value":11292442903},{"value":0},{"value":6186020224},{"value":6186020240},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6186020208},"sp":{"value":6186020160},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"ace_worker0","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":1},{"value":0},{"value":6186593616},{"value":6186593632},{"value":22},{"value":5415053104},{"value":21},{"value":1379020717},{"value":675135217},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6186593600},"sp":{"value":6186593552},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":637180,"imageIndex":4},{"imageOffset":637028,"imageIndex":4},{"imageOffset":563204,"imageIndex":4},{"imageOffset":564916,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"caulk::deferred_logger","threadState":{"x":[{"value":14},{"value":1152851136131088384},{"value":0},{"value":1},{"value":0},{"value":1},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":5406343192},{"value":18446744073709551615},{"value":268419072},{"value":6157348584},{"value":18446744073709551580},{"value":18},{"value":0},{"value":5415273400},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":6157348736},"sp":{"value":6157348704},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":61},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":61},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":61},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"caulk.messenger.shared:high","threadState":{"x":[{"value":14},{"value":84243},{"value":84243},{"value":21},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":1},{"value":5415178712},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":11947658104},{"value":0},{"value":5146229664},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":6173978496},"sp":{"value":6173978464},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":61},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":61},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":61},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ausm_messenger_for_buffer_disposal","threadState":{"x":[{"value":14},{"value":4706089875},{"value":0},{"value":6173405299},{"value":4706089840},{"value":34},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":6173405184},{"value":0},{"value":5650225336},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":6173405056},"sp":{"value":6173405024},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":61},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":61},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":61},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1594748,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":6190608144},{"value":6190608160},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6190608128},"sp":{"value":6190608080},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"GThreadProcess","threadState":{"x":[{"value":4},{"value":0},{"value":355900160},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6191180072},{"value":0},{"value":249385216},{"value":1071101347075281154},{"value":1071101347075281154},{"value":249385216},{"value":0},{"value":1071101347075281152},{"value":305},{"value":4729061095673708888},{"value":0},{"value":5869957208},{"value":5869957272},{"value":6191182048},{"value":0},{"value":0},{"value":355900160},{"value":355900161},{"value":355900416},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6191180192},"sp":{"value":6191180048},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":105896,"imageIndex":32},{"imageOffset":104632,"imageIndex":32},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GThreadProcess","threadState":{"x":[{"value":260},{"value":0},{"value":355900160},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6191753512},{"value":0},{"value":249385472},{"value":1071102446586909186},{"value":1071102446586909186},{"value":249385472},{"value":0},{"value":1071102446586909184},{"value":305},{"value":4729061095673708888},{"value":0},{"value":5869957208},{"value":5869957272},{"value":6191755488},{"value":0},{"value":0},{"value":355900160},{"value":355900160},{"value":355900672},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6191753632},"sp":{"value":6191753488},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":105896,"imageIndex":32},{"imageOffset":104632,"imageIndex":32},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GThreadManager","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":0},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":10},{"value":10},{"value":0},{"value":249385472},{"value":1071102446586909184},{"value":334},{"value":4729061095673708888},{"value":0},{"value":0},{"value":6192327120},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6192327088},"sp":{"value":6192327040},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":105540,"imageIndex":32},{"imageOffset":102668,"imageIndex":32},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ace_rp_queue","threadState":{"x":[{"value":4},{"value":0},{"value":96},{"value":18446726483666796544},{"value":1},{"value":9},{"value":0},{"value":0},{"value":1},{"value":4290131007},{"value":0},{"value":0},{"value":3187477478713707456},{"value":3187459880085209864},{"value":641024},{"value":4621729792},{"value":271},{"value":16141646600},{"value":0},{"value":5145064192},{"value":0},{"value":65536},{"value":5145064728},{"value":5800116224},{"value":0},{"value":3435973837},{"value":214748364},{"value":1717986919},{"value":2103}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4555462444},"cpsr":{"value":2684358656},"fp":{"value":6168817376},"sp":{"value":6168817296},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834389484},"far":{"value":0}},"frames":[{"imageOffset":85996,"symbol":"sem_wait","symbolLocation":8,"imageIndex":47},{"imageOffset":612140,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GVoiceUtil","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":0},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":256},{"value":0},{"value":256},{"value":1099511628032},{"value":334},{"value":8691416560},{"value":0},{"value":0},{"value":6192902016},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6192902000},"sp":{"value":6192901952},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":58},{"imageOffset":175815176,"imageIndex":0},{"imageOffset":174221216,"symbol":"ApolloTVE::CSysThread::GSysThreadProc(void*)","symbolLocation":24,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GVoiceCapture","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":3543824036068086856},{"value":18446726483670988800},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":122368355465313060},{"value":24000000},{"value":159210},{"value":0},{"value":0},{"value":334},{"value":6193475584},{"value":0},{"value":0},{"value":6193467136},{"value":5874882328},{"value":0},{"value":6193467200},{"value":4},{"value":0},{"value":4},{"value":5874984067},{"value":5874973168}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6193467120},"sp":{"value":6193467072},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":58},{"imageOffset":175549688,"imageIndex":0},{"imageOffset":174221216,"symbol":"ApolloTVE::CSysThread::GSysThreadProc(void*)","symbolLocation":24,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"GVoiceCdnv","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":0},{"value":18446726482597246976},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":214784},{"value":0},{"value":214784},{"value":922490255918848},{"value":334},{"value":8691413816},{"value":0},{"value":0},{"value":6194048816},{"value":4705672416},{"value":4705672216},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6194048800},"sp":{"value":6194048752},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":58},{"imageOffset":177054480,"imageIndex":0},{"imageOffset":177038000,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"JavaScriptCore libpas scavenger","threadState":{"x":[{"value":260},{"value":0},{"value":1325537792},{"value":0},{"value":0},{"value":160},{"value":9},{"value":999999072},{"value":6194622120},{"value":0},{"value":797184},{"value":3423879209691650},{"value":3423879209691650},{"value":797184},{"value":0},{"value":3423879209691648},{"value":305},{"value":8691416304},{"value":0},{"value":5964245056},{"value":5964245120},{"value":6194622688},{"value":999999072},{"value":9},{"value":1325537792},{"value":1325539841},{"value":1325540096},{"value":0},{"value":8668708864,"symbolLocation":0,"symbol":"WTF::globalMaxQOSclass"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6194622240},"sp":{"value":6194622096},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":47},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":48},{"imageOffset":29667316,"symbol":"scavenger_thread_main","symbolLocation":1632,"imageIndex":62},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1833920,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":6329413440},{"value":6329413456},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6329413424},"sp":{"value":6329413376},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"Log work queue","threadState":{"x":[{"value":14},{"value":6208160256},{"value":1},{"value":0},{"value":0},{"value":7286396740,"symbolLocation":0,"symbol":"pas_allocation_result_crash_on_error"},{"value":6187167968},{"value":5964333392},{"value":0},{"value":0},{"value":0},{"value":129},{"value":5964333536},{"value":2097153},{"value":20},{"value":36028797014769664},{"value":18446744073709551580},{"value":8691361248},{"value":0},{"value":6106907392},{"value":6106907432},{"value":6187167744},{"value":0},{"value":0},{"value":6106957056},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7371846036},"cpsr":{"value":2147487744},"fp":{"value":6187167568},"sp":{"value":6187167536},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":19763604,"symbol":"WTF::Detail::CallableWrapper<IPC::StreamConnectionWorkQueue::startProcessingThread()::$_0, void>::call()","symbolLocation":52,"imageIndex":63},{"imageOffset":995056,"symbol":"WTF::Thread::entryPoint(WTF::Thread::NewThreadContext*)","symbolLocation":356,"imageIndex":62},{"imageOffset":1009320,"symbol":"WTF::wtfThreadEntryPoint(void*)","symbolLocation":16,"imageIndex":62},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":16351852704},{"value":4467189776},{"value":4500311264},{"value":2305843009213693952},{"value":0},{"value":160035},{"value":18446744073709551615},{"value":5194628616},{"value":5194628616},{"value":15394322944},{"value":5063712856},{"value":576512},{"value":2476100186328064},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":5243842736},{"value":5243842672},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6174863104},"sp":{"value":6174863088},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":16351852224},{"value":4467189776},{"value":4500311264},{"value":3458764513820540928},{"value":0},{"value":40967},{"value":18446744073709551615},{"value":5194311408},{"value":5194311408},{"value":18372465360},{"value":5047509864},{"value":1},{"value":4269544534},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":5243838496},{"value":5243838432},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6176583424},"sp":{"value":6176583408},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":0},{"value":0},{"value":4500311264},{"value":1743},{"value":0},{"value":321551},{"value":18446744073709551615},{"value":15745067728},{"value":15745067728},{"value":16856709984},{"value":4945864184},{"value":1},{"value":657853},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":5243835136},{"value":5243835072},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6331444992},"sp":{"value":6331444976},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":16351843872},{"value":4467189776},{"value":0},{"value":1729382256910270464},{"value":0},{"value":343075},{"value":18446744073709551615},{"value":5222246000},{"value":5222246000},{"value":5659207360},{"value":5032718464},{"value":576768},{"value":2477199697956096},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":5243834976},{"value":5243834912},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":15035232000},"sp":{"value":15035231984},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":156795780,"imageIndex":0},{"imageOffset":160546796,"imageIndex":0},{"imageOffset":160570008,"imageIndex":0},{"imageOffset":162634656,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"com.apple.UIKit.inProcessAnimationManager","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":17179869187},{"value":1},{"value":17179869187},{"value":3},{"value":17179869187},{"value":3},{"value":500035},{"value":18446744073709551615},{"value":8973489792},{"value":15},{"value":9964928},{"value":0},{"value":8664751144,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_dispatch_semaphore"},{"value":8664751144,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_dispatch_semaphore"},{"value":18446744073709551580},{"value":8691400048},{"value":0},{"value":4792935792},{"value":4792935728},{"value":18446744073709551615},{"value":5933190208},{"value":4792935728},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":15087463504},"sp":{"value":15087463488},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":51},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":51},{"imageOffset":4039160,"imageIndex":49},{"imageOffset":4039088,"imageIndex":49},{"imageOffset":263620,"imageIndex":49},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"PingThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":1334940260106240},{"value":0},{"value":1334940260106240},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":310815},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":1334940260106240},{"value":0},{"value":1334940260106240},{"value":21592279046},{"value":6330555816},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6330555664},"sp":{"value":6330555584},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":53},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":53},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":53},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":57},{"imageOffset":62204,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":64,"imageIndex":57},{"imageOffset":856440,"symbol":"+[GSDKPing pingThreadEntryPoint:]","symbolLocation":204,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":57},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"caulk.messenger.shared:21","threadState":{"x":[{"value":14},{"value":4708751290},{"value":0},{"value":15737729130},{"value":4708751264},{"value":25},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":15737729024},{"value":0},{"value":5146228320},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":15737728896},"sp":{"value":15737728864},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":61},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":61},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":61},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"ace_cs2","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":15810997744},{"value":9},{"value":36},{"value":18446726482597246976},{"value":4557287424},{"value":2},{"value":15810997724},{"value":0},{"value":108},{"value":191315023277568},{"value":74496},{"value":319957883757312},{"value":93},{"value":64700838432},{"value":0},{"value":4841406464},{"value":4841406688},{"value":4557627248},{"value":4013},{"value":3226763252},{"value":241638085},{"value":524288},{"value":4},{"value":15810997760},{"value":248706189}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4555302820},"cpsr":{"value":2684358656},"fp":{"value":15810997984},"sp":{"value":15810997744},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834337136},"far":{"value":0}},"frames":[{"imageOffset":33648,"symbol":"__select","symbolLocation":8,"imageIndex":47},{"imageOffset":452516,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15766122496},{"value":1977707},{"value":15765585920},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15766122496},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15749263360},{"value":1417619},{"value":15748726784},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15749263360},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15766695936},{"value":2063475},{"value":15766159360},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15766695936},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15738449920},{"value":1306531},{"value":15737913344},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15738449920},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15761895424},{"value":196355},{"value":15761358848},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15761895424},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15983128576},{"value":2013403},{"value":15982592000},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15983128576},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"name":"ace_worker1","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":2},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":5888},{"value":0},{"value":5888},{"value":25288767444736},{"value":334},{"value":4729061095673708888},{"value":0},{"value":16910298544},{"value":16910298560},{"value":1},{"value":0},{"value":2},{"value":4557729792},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":16910298528},"sp":{"value":16910298480},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":47},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":58},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":58},{"imageOffset":563156,"imageIndex":4},{"imageOffset":564756,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AudioSession - RootQueue","threadState":{"x":[{"value":14},{"value":4294967115611373572},{"value":999999958},{"value":68719460488},{"value":0},{"value":0},{"value":0},{"value":18446726482597246976},{"value":999999958},{"value":3},{"value":13835058055282163714},{"value":80000000},{"value":5169258552},{"value":5217280832},{"value":8664770688,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_os_log"},{"value":8664770688,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_os_log"},{"value":18446744073709551578},{"value":8691361248},{"value":0},{"value":2634239023082},{"value":5167448640},{"value":1000000000},{"value":5167448504},{"value":6165377248},{"value":0},{"value":0},{"value":18446744071411073023},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880882136},"cpsr":{"value":2147487744},"fp":{"value":6165376832},"sp":{"value":6165376800},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306664},"far":{"value":0}},"frames":[{"imageOffset":3176,"symbol":"semaphore_timedwait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":223192,"symbol":"_dispatch_sema4_timedwait","symbolLocation":64,"imageIndex":51},{"imageOffset":14952,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":76,"imageIndex":51},{"imageOffset":79612,"symbol":"_dispatch_worker_thread","symbolLocation":324,"imageIndex":51},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"name":"AURemoteIO::IOThread","threadState":{"x":[{"value":268451845},{"value":17179869186},{"value":0},{"value":7323103923273728},{"value":0},{"value":7323103923273728},{"value":116},{"value":0},{"value":0},{"value":116},{"value":0},{"value":0},{"value":0},{"value":1705043},{"value":0},{"value":93683974144000},{"value":18446744073709551569},{"value":6190034944},{"value":0},{"value":0},{"value":116},{"value":7323103923273728},{"value":0},{"value":7323103923273728},{"value":17179869186},{"value":6190034688},{"value":0},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6190034224},"sp":{"value":6190034144},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":47},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":47},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":47},{"imageOffset":68904,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, AURemoteIO::IOThread::IOThread(AURemoteIO&, caulk::thread::attributes const&, caulk::mach::os_workgroup_managed const&)::'lambda'(), std::__1::tuple<>>>(void*)","symbolLocation":556,"imageIndex":64},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15042211840},{"value":1593947},{"value":15041675264},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15042211840},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":15079075840},{"value":2260563},{"value":15078539264},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":15079075840},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"name":"AudioSession - RootQueue","threadState":{"x":[{"value":14},{"value":5},{"value":0},{"value":68719460488},{"value":16785427776},{"value":0},{"value":0},{"value":0},{"value":0},{"value":3},{"value":13835058055282163714},{"value":80000000},{"value":2217836148615661773},{"value":2217818554282132066},{"value":116736},{"value":4621729792},{"value":18446744073709551578},{"value":53492292194},{"value":0},{"value":2634239027131},{"value":5167448640},{"value":1000000000},{"value":5167448504},{"value":6332018912},{"value":0},{"value":0},{"value":18446744071411073023},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880882136},"cpsr":{"value":2147487744},"fp":{"value":6332018496},"sp":{"value":6332018464},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306664},"far":{"value":0}},"frames":[{"imageOffset":3176,"symbol":"semaphore_timedwait_trap","symbolLocation":8,"imageIndex":47},{"imageOffset":223192,"symbol":"_dispatch_sema4_timedwait","symbolLocation":64,"imageIndex":51},{"imageOffset":14952,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":76,"imageIndex":51},{"imageOffset":79612,"symbol":"_dispatch_worker_thread","symbolLocation":324,"imageIndex":51},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":48},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":48}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6160216064},{"value":81163},{"value":6159679488},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6160216064},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}}],
  "usedImages" : [
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4310089728}},
    "size" : 204603392,
    "uuid" : "{{SLICE_UUID}}",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/cod",
    "name" : "cod"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4551475200}},
    "size" : 1687552,
    "uuid" : "789e17cd-d13f-35d6-97d9-00eb01699395",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/LineSDK.framework\/LineSDK",
    "name" : "LineSDK"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4549132288}},
    "size" : 65536,
    "uuid" : "042997a5-1601-37e0-92d9-5304f4c81262",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAgeRange.framework\/MSDKPIXAgeRange",
    "name" : "MSDKPIXAgeRange"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4553883648}},
    "size" : 344064,
    "uuid" : "ba9f446f-4357-3638-8b1c-420329ab4ec7",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKLoginKit.framework\/FBSDKLoginKit",
    "name" : "FBSDKLoginKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4554850304}},
    "size" : 2719744,
    "uuid" : "012c9348-ff37-38ec-8089-07fdf5e10a07",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/anogs.framework\/anogs",
    "name" : "anogs"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4549312512}},
    "size" : 311296,
    "uuid" : "ed95e02a-12fd-36d3-8149-e39652bae555",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/HelpshiftX.framework\/HelpshiftX",
    "name" : "HelpshiftX"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4557897728}},
    "size" : 344064,
    "uuid" : "0e1ddd7d-b20d-39d3-a484-7b03f479cb53",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKGamingServicesKit.framework\/FBSDKGamingServicesKit",
    "name" : "FBSDKGamingServicesKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4550819840}},
    "size" : 81920,
    "uuid" : "eaea1a4b-7f7b-3b62-a16d-9f5225ea1063",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXGameCenter.framework\/MSDKPIXGameCenter",
    "name" : "MSDKPIXGameCenter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4549967872}},
    "size" : 65536,
    "uuid" : "a052368f-a3a1-3af5-a773-28a4fe12196b",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXUNO.framework\/MSDKPIXUNO",
    "name" : "MSDKPIXUNO"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4559060992}},
    "size" : 49152,
    "uuid" : "77485837-124f-3fe6-9987-99f919fe5909",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXSystem.framework\/MSDKPIXSystem",
    "name" : "MSDKPIXSystem"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4559208448}},
    "size" : 507904,
    "uuid" : "86a4f6d1-63b5-33b3-a714-c7dcfe786011",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/TDataMaster.framework\/TDataMaster",
    "name" : "TDataMaster"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4560175104}},
    "size" : 32768,
    "uuid" : "25026fbe-1e50-3483-8da1-2ad9b09c31df",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightAdapter.framework\/CrashSightAdapter",
    "name" : "CrashSightAdapter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4560273408}},
    "size" : 1245184,
    "uuid" : "4b4cdcfa-144a-33ca-a98f-038c56bdfa67",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GPM_dylib.framework\/GPM_dylib",
    "name" : "GPM_dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4562550784}},
    "size" : 49152,
    "uuid" : "2086552d-0049-3675-9d7e-0d2e17b5b884",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXApple.framework\/MSDKPIXApple",
    "name" : "MSDKPIXApple"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4562681856}},
    "size" : 32768,
    "uuid" : "e564426d-cabd-3e48-b7b0-9a1603ae2f81",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/TDMASA.framework\/TDMASA",
    "name" : "TDMASA"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4562763776}},
    "size" : 32768,
    "uuid" : "dc00db9a-27ab-3bb3-8bad-bb2b26c4b824",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/videotexture.framework\/videotexture",
    "name" : "videotexture"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4562845696}},
    "size" : 344064,
    "uuid" : "c72576aa-6c65-33c6-a0a2-7577ae6e836d",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXWebView.framework\/MSDKPIXWebView",
    "name" : "MSDKPIXWebView"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4563501056}},
    "size" : 688128,
    "uuid" : "e3c82398-46d1-388a-96f3-98a3d93ca328",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GCloudCore.framework\/GCloudCore",
    "name" : "GCloudCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4564828160}},
    "size" : 245760,
    "uuid" : "ac9592c9-aa67-35fb-9e23-9f3ede984913",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBAEMKit.framework\/FBAEMKit",
    "name" : "FBAEMKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4565450752}},
    "size" : 1277952,
    "uuid" : "20ab51da-9e05-37f4-9919-1147ae5b5fbd",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXCore.framework\/MSDKPIXCore",
    "name" : "MSDKPIXCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4569071616}},
    "size" : 65536,
    "uuid" : "5cebc6ee-3bdc-3d61-a494-a9db5609d7d5",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXLine.framework\/MSDKPIXLine",
    "name" : "MSDKPIXLine"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4569268224}},
    "size" : 1015808,
    "uuid" : "a173f8f8-e72b-3686-b77d-9aa011d69110",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSight.framework\/CrashSight",
    "name" : "CrashSight"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4571316224}},
    "size" : 5963776,
    "uuid" : "47279944-76a8-3a9e-8155-1f1a69996ee3",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PxKit3.framework\/PxKit3",
    "name" : "PxKit3"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4579622912}},
    "size" : 32768,
    "uuid" : "a8405d09-048c-3b1a-9ec9-1ba91d9a3183",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PluginCrosCurl.framework\/PluginCrosCurl",
    "name" : "PluginCrosCurl"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4579721216}},
    "size" : 32768,
    "uuid" : "9ce39a89-e5e9-3abc-a49b-d0714d031401",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GPixUI.framework\/GPixUI",
    "name" : "GPixUI"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4579819520}},
    "size" : 2064384,
    "uuid" : "2bac3286-cc10-3faa-bb02-6f84a3d39864",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/LineSDKObjC.framework\/LineSDKObjC",
    "name" : "LineSDKObjC"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4582834176}},
    "size" : 163840,
    "uuid" : "8cee3d3a-f704-3985-8559-646260d61f15",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAdapter.framework\/MSDKPIXAdapter",
    "name" : "MSDKPIXAdapter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4583243776}},
    "size" : 32768,
    "uuid" : "acc1ad31-235e-39c2-bc83-3fe3909fc52e",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXTDM.framework\/MSDKPIXTDM",
    "name" : "MSDKPIXTDM"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4583342080}},
    "size" : 32768,
    "uuid" : "9171c5c3-bc6e-36ec-aeb4-f67e52af26e2",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPolicy.framework\/MSDKPolicy",
    "name" : "MSDKPolicy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4583424000}},
    "size" : 49152,
    "uuid" : "53387f9f-2ca5-3522-80b9-534de9c18a84",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAppsFlyer.framework\/MSDKPIXAppsFlyer",
    "name" : "MSDKPIXAppsFlyer"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4583620608}},
    "size" : 1245184,
    "uuid" : "7e56c197-9bc6-3bc0-97b8-e87abaabd89c",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKCoreKit.framework\/FBSDKCoreKit",
    "name" : "FBSDKCoreKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4587028480}},
    "size" : 278528,
    "uuid" : "5cb7f8ab-b746-3481-8a0b-bc2738410394",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKShareKit.framework\/FBSDKShareKit",
    "name" : "FBSDKShareKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4587847680}},
    "size" : 17891328,
    "uuid" : "36a4c1de-f7c2-3210-8c64-05a2ad6353ea",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GCloud.framework\/GCloud",
    "name" : "GCloud"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4606803968}},
    "size" : 393216,
    "uuid" : "88e748d7-46a0-33aa-aa43-31d045548ac3",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/enq_transceiver_dy.framework\/enq_transceiver_dy",
    "name" : "enq_transceiver_dy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4607508480}},
    "size" : 49152,
    "uuid" : "5b47ada5-3e79-3ccb-88b3-009df3fb7295",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightPlugin.framework\/CrashSightPlugin",
    "name" : "CrashSightPlugin"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4607639552}},
    "size" : 32768,
    "uuid" : "b5c35e91-a5ae-3419-afd5-a11b6d68d364",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/APMDeviceInfoSupport_dylib.framework\/APMDeviceInfoSupport_dylib",
    "name" : "APMDeviceInfoSupport_dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4607721472}},
    "size" : 442368,
    "uuid" : "7548dc41-8466-332b-ab3a-3facf7b2a30a",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PxEmbedded.framework\/PxEmbedded",
    "name" : "PxEmbedded"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4609392640}},
    "size" : 81920,
    "uuid" : "21471420-b035-3be4-ab03-dd3d65378d9d",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXFacebook.framework\/MSDKPIXFacebook",
    "name" : "MSDKPIXFacebook"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4609654784}},
    "size" : 409600,
    "uuid" : "b2dbfcaf-c010-3f32-b3fa-7622cab07a78",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/crosCurl.framework\/crosCurl",
    "name" : "crosCurl"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4610179072}},
    "size" : 147456,
    "uuid" : "f042e662-c341-3f44-b6f4-36ed32655f31",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPopup.framework\/MSDKPopup",
    "name" : "MSDKPopup"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4610457600}},
    "size" : 3686400,
    "uuid" : "d1db61c9-0b90-3667-8f4c-1ddb0b80514f",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PixVideo.framework\/PixVideo",
    "name" : "PixVideo"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4616863744}},
    "size" : 32768,
    "uuid" : "a96d62b0-46ed-3b75-9445-608678ed8336",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXSensitivity.framework\/MSDKPIXSensitivity",
    "name" : "MSDKPIXSensitivity"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4616945664}},
    "size" : 425984,
    "uuid" : "2e2fc0e2-16ac-3955-af09-cc66a0e34d39",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/AppsFlyerLib.framework\/AppsFlyerLib",
    "name" : "AppsFlyerLib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4617846784}},
    "size" : 98304,
    "uuid" : "d41c7c18-e896-3e8d-b978-73bed639f192",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightCore.framework\/CrashSightCore",
    "name" : "CrashSightCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4618108928}},
    "size" : 753664,
    "uuid" : "167bff7e-e558-3007-8424-0c95998ca46b",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/kgvmp_dy.framework\/kgvmp_dy",
    "name" : "kgvmp_dy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4619370496}},
    "size" : 65536,
    "uuid" : "6ed9543d-d000-3c65-a476-da0b5450fce2",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKCoreKit_Basics.framework\/FBSDKCoreKit_Basics",
    "name" : "FBSDKCoreKit_Basics"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:4696227840}},
    "size" : 49152,
    "uuid" : "004ce93c-f142-3d68-b3c3-30c6efef4d65",
    "path" : "\/private\/preboot\/Cryptexes\/OS\/usr\/lib\/libobjc-trampolines.dylib",
    "name" : "libobjc-trampolines.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:9834303488}},
    "size" : 244512,
    "uuid" : "18665b3f-6d51-33ab-b9e9-63062200ec42",
    "path" : "\/usr\/lib\/system\/libsystem_kernel.dylib",
    "name" : "libsystem_kernel.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:8499109888}},
    "size" : 50416,
    "uuid" : "34b44744-bc64-386e-ab90-eee86b23ac46",
    "path" : "\/usr\/lib\/system\/libsystem_pthread.dylib",
    "name" : "libsystem_pthread.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6992625664}},
    "size" : 39073344,
    "uuid" : "0d94422f-fe7c-302e-b896-3bc5873c0cfc",
    "path" : "\/System\/Library\/PrivateFrameworks\/UIKitCore.framework\/UIKitCore",
    "name" : "UIKitCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7451979776}},
    "size" : 929920,
    "uuid" : "cdb80f7a-3de2-32f4-9a09-7de06100970c",
    "path" : "\/System\/Library\/PrivateFrameworks\/FrontBoardServices.framework\/FrontBoardServices",
    "name" : "FrontBoardServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7880658944}},
    "size" : 288256,
    "uuid" : "49c0cd3e-a696-3b11-ba92-5755f0c3c6e3",
    "path" : "\/usr\/lib\/system\/libdispatch.dylib",
    "name" : "libdispatch.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7304511488}},
    "size" : 544096,
    "uuid" : "2fe35d43-52cf-3d5a-bfbf-04b3943c4af1",
    "path" : "\/System\/Library\/PrivateFrameworks\/BoardServices.framework\/BoardServices",
    "name" : "BoardServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6895890432}},
    "size" : 5884480,
    "uuid" : "101eb2f1-1915-34a0-8bc9-631d03753b84",
    "path" : "\/System\/Library\/Frameworks\/CoreFoundation.framework\/CoreFoundation",
    "name" : "CoreFoundation"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:9676554240}},
    "size" : 34752,
    "uuid" : "411165e2-ee8e-380e-b254-9977273971e3",
    "path" : "\/System\/Library\/PrivateFrameworks\/GraphicsServices.framework\/GraphicsServices",
    "name" : "GraphicsServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6841585664}},
    "size" : 676992,
    "uuid" : "0f8d35b6-556f-3e34-8eaa-80ab54047dc5",
    "path" : "\/usr\/lib\/dyld",
    "name" : "dyld"
  },
  {
    "size" : 0,
    "source" : "A",
    "base" : {{IMG_BASE:0}},
    "uuid" : "00000000-0000-0000-0000-000000000000"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6848249856}},
    "size" : 15244480,
    "uuid" : "73841aa3-bfdd-322d-8dc2-e5185a14dee1",
    "path" : "\/System\/Library\/Frameworks\/Foundation.framework\/Foundation",
    "name" : "Foundation"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7092486144}},
    "size" : 521728,
    "uuid" : "ff429821-80de-3a68-99cb-0b2e707e8d48",
    "path" : "\/usr\/lib\/system\/libsystem_c.dylib",
    "name" : "libsystem_c.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7253114880}},
    "size" : 3868544,
    "uuid" : "3ae849fe-8a7d-388c-86ef-64dedb9fc5c6",
    "path" : "\/System\/Library\/Frameworks\/CFNetwork.framework\/CFNetwork",
    "name" : "CFNetwork"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7316545536}},
    "size" : 4551488,
    "uuid" : "33533ca9-f9fb-3516-af0a-03c1b9469f97",
    "path" : "\/System\/Library\/Frameworks\/CoreMotion.framework\/CoreMotion",
    "name" : "CoreMotion"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:11622313984}},
    "size" : 167968,
    "uuid" : "5dd354fb-a86f-3732-8f36-a88736414f79",
    "path" : "\/System\/Library\/PrivateFrameworks\/caulk.framework\/caulk",
    "name" : "caulk"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7256985600}},
    "size" : 32251488,
    "uuid" : "f7906028-1c6d-3b4c-bd93-78c196c83a83",
    "path" : "\/System\/Library\/Frameworks\/JavaScriptCore.framework\/JavaScriptCore",
    "name" : "JavaScriptCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7352082432}},
    "size" : 24644064,
    "uuid" : "c39bd22c-3475-38af-91bd-0b7574081011",
    "path" : "\/System\/Library\/Frameworks\/WebKit.framework\/WebKit",
    "name" : "WebKit"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:10008899584}},
    "size" : 1153340,
    "uuid" : "e128c965-66cf-382d-bef0-6d685e7a282e",
    "path" : "\/System\/Library\/Frameworks\/AudioToolbox.framework\/libEmbeddedSystemAUs.dylib",
    "name" : "libEmbeddedSystemAUs.dylib"
  }
],
  "sharedCache" : {
  "base" : {{IMG_BASE:6840418304}},
  "size" : 5383520256,
  "uuid" : "a0faea75-70ff-3a53-8881-bc6fe2b6c70b"
},
  "vmSummary" : "ReadOnly portion of Libraries: Total=2.3G resident=0K(0%) swapped_out_or_unallocated=2.3G(100%)\nWritable regions: Total=5.5G written=3132K(0%) resident=3052K(0%) swapped_out=96K(0%) unallocated=5.5G(100%)\n\n                                VIRTUAL   REGION \nREGION TYPE                        SIZE    COUNT (non-coalesced) \n===========                     =======  ======= \nActivity Tracing                   256K        1 \nAttributeGraph Data               1024K        1 \nAudio                               64K        1 \nCG raster data                     992K       10 \nColorSync                           16K        1 \nCoreAnimation                      256K       11 \nFoundation                         608K        7 \nImage IO                          4112K        2 \nJS VM Gigacage (reserved)          2.0G        1         reserved VM address space (unallocated)\nKernel Alloc Once                   32K        1 \nMALLOC                             1.9G      500 \nMALLOC guard page                 3568K        4 \nMach message                      21.2M     1359 \nMemory Tag 22                     64.0M        1 \nSQLite page cache                 1408K       11 \nSTACK GUARD                        896K       56 \nStack                             29.2M       56 \nVM_ALLOCATE                        1.3G    17804 \nVM_ALLOCATE (media)               10.0M        1 \nVM_ALLOCATE (reserved)             560K        5         reserved VM address space (unallocated)\nWebKit Malloc                    224.1M        8 \nWebKit Malloc (reserved)          64.0M        1         reserved VM address space (unallocated)\n__AUTH                            12.0M      987 \n__AUTH_CONST                     127.1M     1436 \n__CTF                               824        1 \n__DATA                            79.3M     1435 \n__DATA_CONST                      54.0M     1449 \n__DATA_DIRTY                      12.3M     1251 \n__FONT_DATA                        2352        1 \n__LINKEDIT                       203.3M       48 \n__OBJC_RO                         84.8M        1 \n__OBJC_RW                         3182K        1 \n__TEXT                             2.1G     1509 \n__TPRO_CONST                       128K        2 \ndyld private memory                128K        1 \nmapped file                      420.6M      500 \npage table in kernel              3052K        1 \nshared memory                       80K        4 \n===========                     =======  ======= \nTOTAL                              8.7G    28469 \nTOTAL, minus reserved VM space     6.6G    28469 \n",
  "legacyInfo" : {
  "threadTriggered" : {
    "queue" : "com.apple.main-thread"
  }
},
  "logWritingSignature" : "{{LOG_SIGNATURE}}",
  "bug_type" : "309",
  "roots_installed" : 0,
  "trmStatus" : 1,
  "sandboxProfileName" : "container",
  "voucherInfos" : [{"originatorName":"SpringBoard","proximateName":"SpringBoard","thread_id":594518}],
  "trialInfo" : {
  "rollouts" : [
    {
      "rolloutId" : "6434420a89ec2e0a7a38bf5a",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000011
    },
    {
      "rolloutId" : "64628732bf2f5257dedc8988",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000001
    }
  ],
  "experiments" : [
    {
      "treatmentId" : "d5c127b8-b13e-42a1-acf5-c483124a1bb5",
      "experimentId" : "66b1602abe27b2208fd291ba",
      "deploymentId" : 400000022
    },
    {
      "treatmentId" : "582596be-1d4a-408d-901b-5b311c006a4a",
      "experimentId" : "65f31ccb74b6f500a45abda4",
      "deploymentId" : 400000026
    }
  ]
}
}

"""#

    /// 46 threads, 62 loaded images.
    static let templateC = #"""
{"app_name":"cod","timestamp":"{{TIMESTAMP}}","app_version":"{{APP_VERSION}}","slice_uuid":"{{SLICE_UUID}}","adam_id":"1287282214","build_version":"{{APP_BUILD}}","bundleID":"com.activision.callofduty.shooter","platform":2,"share_with_app_devs":1,"is_first_party":0,"bug_type":"309","os_version":"{{OS_VERSION_FULL}}","roots_installed":0,"incident_id":"{{INCIDENT}}","name":"cod"}
{
  "uptime" : {{UPTIME}},
  "procRole" : "Non UI",
  "version" : 2,
  "userID" : 501,
  "deployVersion" : 210,
  "modelCode" : "{{MODEL_CODE}}",
  "coalitionID" : {{COALITION_ID}},
  "osVersion" : {
    "isEmbedded" : true,
    "train" : "{{OS_TRAIN}}",
    "releaseType" : "User",
    "build" : "{{OS_BUILD}}"
  },
  "captureTime" : "{{CAPTURE_TIME}}",
  "codeSigningMonitor" : 1,
  "incident" : "{{INCIDENT}}",
  "pid" : {{PID}},
  "translated" : false,
  "cpuType" : "ARM-64",
  "procLaunch" : "{{PROC_LAUNCH}}",
  "procStartAbsTime" : {{PROC_START_ABS}},
  "procExitAbsTime" : {{PROC_EXIT_ABS}},
  "procName" : "cod",
  "procPath" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/cod",
  "bundleInfo" : {"CFBundleShortVersionString":"{{APP_VERSION}}","CFBundleVersion":"{{APP_BUILD}}","CFBundleIdentifier":"com.activision.callofduty.shooter","DTAppStoreToolsBuild":"17F106"},
  "storeInfo" : {"itemID":"1287282214","storeCohortMetadata":"{{STORE_COHORT}}","distributorID":"com.apple.AppStore","deviceIdentifierForVendor":"{{IDFV}}","softwareVersionExternalIdentifier":"{{SW_EXT_ID}}","applicationVariant":"1:{{MODEL_CODE}}:18","thirdParty":true},
  "parentProc" : "launchd",
  "parentPid" : 1,
  "coalitionName" : "com.activision.callofduty.shooter",
  "crashReporterKey" : "{{CRASH_REPORTER_KEY}}",
  "appleIntelligenceStatus" : {"state":"available"},
  "bootProgressRegister" : "0x20800004",
  "wasUnlockedSinceBoot" : 1,
  "isLocked" : 0,
  "codeSigningID" : "com.activision.callofduty.shooter",
  "codeSigningTeamID" : "6KZFBJ4CBY",
  "codeSigningFlags" : 570450689,
  "codeSigningValidationCategory" : 4,
  "codeSigningTrustLevel" : 7,
  "codeSigningAuxiliaryInfo" : 0,
  "instructionByteStream" : {"beforePC":"fyMD1f17v6n9AwCRuwAAlL8DAJH9e8Go\/w9f1sADX9YwJoDSARAA1A==","atPC":"AwEAVH8jA9X9e7+p\/QMAkcIAAJS\/AwCR\/XvBqP8PX9bAA1\/WkCqA0g=="},
  "bootSessionUUID" : "{{BOOT_SESSION}}",
  "exception" : {"codes":"0x0000000000000000, 0x0000000000000000","rawCodes":[0,0],"type":"EXC_CRASH","signal":"SIGKILL"},
  "termination" : {"code":2343432205,"flags":6,"namespace":"FRONTBOARD","reasons":["<RBSTerminateContext| domain:10 code:0x8BADF00D explanation:[app<com.activision.callofduty.shooter>:{{PID}}] Failed to terminate gracefully after 5.0s","ProcessVisibility: Unknown","ProcessState: Running","WatchdogEvent: process-exit","WatchdogVisibility: Background","WatchdogCPUStatistics: (","\"Elapsed total CPU time (seconds): {{CPU_TOTAL}} (user {{CPU_USER}}, system {{CPU_SYS}}), {{CPU_PCT}}% CPU\",","\"Elapsed application CPU time (seconds): {{CPU_APP}}, {{CPU_APP_PCT}}% CPU\"",")","ThermalInfo: (","\"Thermal Level:   0\",","\"Thermal State:   nominal\"",") reportType:CrashLog maxTerminationResistance:Interactive>"]},
  "faultingThread" : 0,
  "threads" : [{"triggered":true,"id":{{TID}},"threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6101356200},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":8664818112,"symbolLocation":0,"symbol":"_main_thread"},{"value":0},{"value":15371245064},{"value":15371245128},{"value":8664818336,"symbolLocation":224,"symbol":"_main_thread"},{"value":0},{"value":0},{"value":0},{"value":1},{"value":256},{"value":3777893186295716171},{"value":4294967295}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6101356320},"sp":{"value":6101356176},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576,"matchesCrashFrame":1},"far":{"value":0}},"queue":"com.apple.main-thread","frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":154559880,"imageIndex":0},{"imageOffset":154543220,"imageIndex":0},{"imageOffset":154936104,"imageIndex":0},{"imageOffset":154909060,"imageIndex":0},{"imageOffset":163818080,"imageIndex":0},{"imageOffset":164428564,"imageIndex":0},{"imageOffset":164429072,"imageIndex":0},{"imageOffset":39584,"imageIndex":0},{"imageOffset":799108,"symbol":"CA::Display::DisplayLinkItem::dispatch_(CA::SignPost::Interval<(CA::SignPost::CAEventCode)835322056>&)","symbolLocation":64,"imageIndex":46},{"imageOffset":634988,"symbol":"CA::Display::DisplayLink::dispatch_items(unsigned long long, unsigned long long, unsigned long long)","symbolLocation":868,"imageIndex":46},{"imageOffset":728256,"symbol":"CA::Display::DisplayLink::dispatch_deferred_display_links(unsigned int)","symbolLocation":364,"imageIndex":46},{"imageOffset":1029844,"symbol":"_UIUpdateSequenceRunNext","symbolLocation":128,"imageIndex":47},{"imageOffset":1018976,"symbol":"schedulerStepScheduledMainSectionContinue","symbolLocation":60,"imageIndex":47},{"imageOffset":5484,"symbol":"UC::DriverCore::continueProcessing()","symbolLocation":84,"imageIndex":48},{"imageOffset":139736,"symbol":"__CFMachPortPerform","symbolLocation":168,"imageIndex":49},{"imageOffset":411732,"symbol":"__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__","symbolLocation":60,"imageIndex":49},{"imageOffset":411516,"symbol":"__CFRunLoopDoSource1","symbolLocation":504,"imageIndex":49},{"imageOffset":194276,"symbol":"__CFRunLoopRun","symbolLocation":2168,"imageIndex":49},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":49},{"imageOffset":5272,"symbol":"GSEventRunModal","symbolLocation":120,"imageIndex":50},{"imageOffset":1185392,"symbol":"-[UIApplication _run]","symbolLocation":796,"imageIndex":47},{"imageOffset":573784,"symbol":"UIApplicationMain","symbolLocation":332,"imageIndex":47},{"imageOffset":16592,"imageIndex":0},{"imageOffset":19484,"symbol":"start","symbolLocation":6928,"imageIndex":51}]},{"id":{{TID}},"name":"com.apple.uikit.eventfetch-thread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":52789443035136},{"value":0},{"value":52789443035136},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":12291},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":52789443035136},{"value":0},{"value":52789443035136},{"value":21592279046},{"value":6104210824},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6104210672},"sp":{"value":6104210592},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":44},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":44},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":44},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":49},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":49},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":49},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":53},{"imageOffset":43992,"symbol":"-[NSRunLoop(NSRunLoop) runUntilDate:]","symbolLocation":64,"imageIndex":53},{"imageOffset":945836,"symbol":"-[UIEventFetcher threadMain]","symbolLocation":420,"imageIndex":47},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"threadState":{"x":[{"value":260},{"value":0},{"value":50944},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6105361544},{"value":0},{"value":16384},{"value":70368744194050},{"value":70368744194050},{"value":16384},{"value":0},{"value":70368744194048},{"value":305},{"value":8691416320},{"value":0},{"value":4754335216},{"value":4754335280},{"value":6105362656},{"value":0},{"value":0},{"value":50944},{"value":50945},{"value":51200},{"value":6105362816},{"value":1535}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6105361664},"sp":{"value":6105361520},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"id":{{TID}},"name":"MSDK-Engine-3","queue":"MSDKThread","frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":52172,"symbol":"std::__1::condition_variable::wait(std::__1::unique_lock<std::__1::mutex>&)","symbolLocation":32,"imageIndex":54},{"imageOffset":148456,"symbol":"void std::__1::condition_variable::wait<GCloud::MSDK::MSDKQJSBaseEngine::Loop()::$_1>(std::__1::unique_lock<std::__1::mutex>&, GCloud::MSDK::MSDKQJSBaseEngine::Loop()::$_1)","symbolLocation":52,"imageIndex":19},{"imageOffset":148284,"symbol":"GCloud::MSDK::MSDKQJSBaseEngine::Loop()","symbolLocation":168,"imageIndex":19},{"imageOffset":182724,"symbol":"GCloud::MSDK::MSDKQJSBaseEngine::Start()::$_2::operator()() const","symbolLocation":60,"imageIndex":19},{"imageOffset":2257672,"symbol":"std::__1::__function::__value_func<void ()>::operator()() const","symbolLocation":60,"imageIndex":19},{"imageOffset":2194652,"symbol":"std::__1::function<void ()>::operator()() const","symbolLocation":24,"imageIndex":19},{"imageOffset":6568,"symbol":"_dispatch_call_block_and_release","symbolLocation":32,"imageIndex":55},{"imageOffset":111076,"symbol":"_dispatch_client_callout","symbolLocation":16,"imageIndex":55},{"imageOffset":24904,"symbol":"_dispatch_continuation_pop","symbolLocation":596,"imageIndex":55},{"imageOffset":22468,"symbol":"_dispatch_async_redirect_invoke","symbolLocation":580,"imageIndex":55},{"imageOffset":80128,"symbol":"_dispatch_root_queue_drain","symbolLocation":360,"imageIndex":55},{"imageOffset":82072,"symbol":"_dispatch_worker_thread2","symbolLocation":184,"imageIndex":55},{"imageOffset":4980,"symbol":"_pthread_wqthread","symbolLocation":232,"imageIndex":45},{"imageOffset":2240,"symbol":"start_wqthread","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"TDM-report-1","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":6107655888},{"value":6107655904},{"value":3435973837},{"value":2},{"value":1374389535},{"value":50},{"value":0},{"value":1},{"value":1},{"value":5982}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6107655872},"sp":{"value":6107655824},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":56},{"imageOffset":206100,"symbol":"TDM::TDataMasterReporter::LoopReportData()","symbolLocation":392,"imageIndex":10},{"imageOffset":205056,"symbol":"TDM::TDataMasterReporter::ProcessSingleThread(void*)","symbolLocation":64,"imageIndex":10},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"OperationQueue.ThreadProcess","threadState":{"x":[{"value":4},{"value":0},{"value":256},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6108229320},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":4729061095673708888},{"value":0},{"value":4752988568},{"value":4752988632},{"value":6108229856},{"value":0},{"value":0},{"value":256},{"value":257},{"value":512},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6108229440},"sp":{"value":6108229296},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":214936,"symbol":"ABase::CCondition::Wait()","symbolLocation":52,"imageIndex":17},{"imageOffset":214400,"symbol":"ABase::OperationQueueImp::onThreadProc(void*)","symbolLocation":348,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"OperationQueue.ThreadProcess","threadState":{"x":[{"value":260},{"value":0},{"value":256},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6108802760},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":4729061095673708888},{"value":0},{"value":4752988568},{"value":4752988632},{"value":6108803296},{"value":0},{"value":0},{"value":256},{"value":256},{"value":768},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6108802880},"sp":{"value":6108802736},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":214936,"symbol":"ABase::CCondition::Wait()","symbolLocation":52,"imageIndex":17},{"imageOffset":214400,"symbol":"ABase::OperationQueueImp::onThreadProc(void*)","symbolLocation":348,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"OperationQueue.ThreadManager","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":0},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":0},{"value":6109376320},{"value":4752988632},{"value":4752988520},{"value":0},{"value":4752414976},{"value":0},{"value":4621365248,"symbolLocation":56,"symbol":"vtable for ABase::_tagApolloActionBufferBase"},{"value":10},{"value":1788798899161}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6109376304},"sp":{"value":6109376256},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":214796,"symbol":"ABase::SleepMS(long long)","symbolLocation":80,"imageIndex":17},{"imageOffset":213876,"symbol":"ABase::OperationQueueImp::onThreadManageProc(void*)","symbolLocation":428,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"XLogThread","threadState":{"x":[{"value":260},{"value":0},{"value":0},{"value":0},{"value":0},{"value":65704},{"value":86400},{"value":0},{"value":6121991832},{"value":0},{"value":0},{"value":2},{"value":2},{"value":0},{"value":0},{"value":0},{"value":305},{"value":2},{"value":0},{"value":4803933888},{"value":4805610688},{"value":6121992416},{"value":0},{"value":86400},{"value":0},{"value":1},{"value":256},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6121991952},"sp":{"value":6121991808},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":186472,"symbol":"ABase::CCondition::TimeWait(unsigned int)","symbolLocation":172,"imageIndex":17},{"imageOffset":184100,"symbol":"ABase::Logger::_XLogThread(void*)","symbolLocation":60,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"CThreadBase","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":1842383970042539714},{"value":24000000},{"value":2397121},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":0},{"value":6127152912},{"value":4812805696},{"value":4812805624},{"value":4812805768},{"value":4621186820,"symbolLocation":25326,"symbol":"ABase::base64_chars2"},{"value":4621176577,"symbolLocation":15083,"symbol":"ABase::base64_chars2"},{"value":1},{"value":4621187452,"symbolLocation":25958,"symbol":"ABase::base64_chars2"},{"value":4621187544,"symbolLocation":26050,"symbol":"ABase::base64_chars2"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6127152896},"sp":{"value":6127152848},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":284844,"symbol":"ABase::CThreadBase::Sleep(int)","symbolLocation":84,"imageIndex":17},{"imageOffset":232332,"symbol":"ABase::CTimerImp::OnThreadProc()","symbolLocation":168,"imageIndex":17},{"imageOffset":284188,"symbol":"ABase::CThreadBase::onThreadProc(void*)","symbolLocation":704,"imageIndex":17},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"GC Finalizer","threadState":{"x":[{"value":260},{"value":0},{"value":32000},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6127726136},{"value":0},{"value":256},{"value":1099511628034},{"value":1099511628034},{"value":256},{"value":0},{"value":1099511628032},{"value":305},{"value":9895604652544},{"value":0},{"value":4752567560},{"value":4752567624},{"value":6127726816},{"value":0},{"value":0},{"value":32000},{"value":32001},{"value":32256},{"value":3777893186295716171},{"value":4294967295}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6127726256},"sp":{"value":6127726112},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":154559880,"imageIndex":0},{"imageOffset":154285452,"imageIndex":0},{"imageOffset":154543020,"imageIndex":0},{"imageOffset":154569788,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"Loading.AsyncRead","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":4801314832},{"value":0},{"value":4555960720},{"value":574},{"value":574},{"value":44291},{"value":18446744073709551615},{"value":128642860479746},{"value":4294967293},{"value":29952},{"value":0},{"value":29952},{"value":128642860479744},{"value":18446744073709551580},{"value":18239057920},{"value":0},{"value":4812202176},{"value":4812202112},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6128873168},"sp":{"value":6128873152},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":156801380,"imageIndex":0},{"imageOffset":159130800,"imageIndex":0},{"imageOffset":159129248,"imageIndex":0},{"imageOffset":162816540,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"com.apple.NSURLConnectionLoader","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":127710852546560},{"value":0},{"value":127710852546560},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":29735},{"value":44032},{"value":189116000021504},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":127710852546560},{"value":0},{"value":127710852546560},{"value":21592279046},{"value":6107077960},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6107077808},"sp":{"value":6107077728},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":44},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":44},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":44},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":49},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":49},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":49},{"imageOffset":596820,"symbol":"+[__CFN_CoreSchedulingSetRunnable _run:]","symbolLocation":416,"imageIndex":57},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"UnityGfxDeviceWorker","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":68719460488},{"value":5683566016},{"value":6109948799},{"value":0},{"value":0},{"value":80387},{"value":18446744073709551615},{"value":674164},{"value":4524980084},{"value":1800},{"value":62336721811190126},{"value":309248},{"value":4672307200},{"value":18446744073709551580},{"value":59448930670},{"value":0},{"value":5172183904},{"value":5172183840},{"value":18446744073709551615},{"value":5090784452},{"value":3929017994820},{"value":10000},{"value":674164},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6109948800},"sp":{"value":6109948784},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":156801380,"imageIndex":0},{"imageOffset":162819048,"imageIndex":0},{"imageOffset":159456008,"imageIndex":0},{"imageOffset":164893604,"imageIndex":0},{"imageOffset":159489056,"imageIndex":0},{"imageOffset":159455760,"imageIndex":0},{"imageOffset":162816540,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"mgpa_handler","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":410130722062336},{"value":0},{"value":410130722062336},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":95491},{"value":1280},{"value":5497558140160},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":410130722062336},{"value":0},{"value":410130722062336},{"value":21592279046},{"value":6123134360},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6123134208},"sp":{"value":6123134128},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":44},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":44},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":44},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":49},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":49},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":49},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":53},{"imageOffset":62204,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":64,"imageIndex":53},{"imageOffset":27600,"symbol":"-[MGPAMsgServer startMainHandlerRunloop]","symbolLocation":244,"imageIndex":41},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"APM-IOS-WorkThread","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":1},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":63},{"value":2607872},{"value":5163666384},{"value":72057602702767201,"symbolLocation":72057594037927937,"symbol":"OBJC_CLASS_$___NSCFString"},{"value":8664839264,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSCFString"},{"value":334},{"value":6895959556,"symbolLocation":0,"symbol":"-[__NSCFString release]"},{"value":0},{"value":6123710256},{"value":6123710272},{"value":4618321365},{"value":8903882648,"objc-selector":"sharedManager"},{"value":4618321408},{"value":4618321684},{"value":4756311808},{"value":8889338136,"objc-selector":"sharedInstance"},{"value":5788},{"value":4618321562}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6123710240},"sp":{"value":6123710192},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":56},{"imageOffset":195048,"symbol":"-[TApmApiSingleInstance startWorkThread]","symbolLocation":2784,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"APM-IOS-UploadThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":96},{"value":18446726483666796544},{"value":15657617472},{"value":6130588008},{"value":6130588004},{"value":6130587992},{"value":118531},{"value":18446744073709551615},{"value":0},{"value":0},{"value":735302395399106686},{"value":735284801065577276},{"value":126976},{"value":4672307200},{"value":18446744073709551580},{"value":14027463484},{"value":0},{"value":5262099616},{"value":5262099552},{"value":18446744073709551615},{"value":8889338136,"objc-selector":"sharedInstance"},{"value":4618300401},{"value":4618307713},{"value":4618307782},{"value":15657630720},{"value":15657630720},{"value":5091233968}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6130592848},"sp":{"value":6130592832},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":198560,"symbol":"-[TApmApiSingleInstance startUploadThread]","symbolLocation":132,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"ace_schedule3","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":6131740272},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":4611685024},{"value":10961533882666647746},{"value":6},{"value":3998368724},{"value":24000000},{"value":2857220},{"value":1280},{"value":5497558140160},{"value":93},{"value":8691413816},{"value":0},{"value":5091524928},{"value":0},{"value":1},{"value":0},{"value":3266728883},{"value":2756327217},{"value":4613946432},{"value":2032324052},{"value":342936582},{"value":38274408}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4611712176},"cpsr":{"value":2684358656},"fp":{"value":6131740384},"sp":{"value":6131740128},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834337136},"far":{"value":0}},"frames":[{"imageOffset":33648,"symbol":"__select","symbolLocation":8,"imageIndex":44},{"imageOffset":550064,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":56},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1439664,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":60},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":8691414312},{"value":0},{"value":6134034192},{"value":6134034208},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6134034176},"sp":{"value":6134034128},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":56},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1617124,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":50522361979},{"value":0},{"value":6136327552},{"value":6136327568},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6136327536},"sp":{"value":6136327488},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"ace_worker0","threadState":{"x":[{"value":4},{"value":0},{"value":73896},{"value":68719460488},{"value":0},{"value":32},{"value":0},{"value":6136895432},{"value":1},{"value":4},{"value":5},{"value":4294967293},{"value":1280},{"value":0},{"value":1280},{"value":5497558140160},{"value":271},{"value":1},{"value":0},{"value":4803857920},{"value":0},{"value":4803858072},{"value":4613947376},{"value":2835083243},{"value":1379020717},{"value":675135217},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4611726968},"cpsr":{"value":536875008},"fp":{"value":6136901344},"sp":{"value":6136901264},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834389484},"far":{"value":0}},"frames":[{"imageOffset":85996,"symbol":"sem_wait","symbolLocation":8,"imageIndex":44},{"imageOffset":564856,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"caulk::deferred_logger","threadState":{"x":[{"value":14},{"value":1152851136131088384},{"value":0},{"value":1},{"value":0},{"value":1},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":5171363864},{"value":18446744073709551615},{"value":268419072},{"value":6137474792},{"value":18446744073709551580},{"value":18},{"value":0},{"value":5172870072},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":6137474944},"sp":{"value":6137474912},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":58},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":58},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":58},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"caulk.messenger.shared:high","threadState":{"x":[{"value":14},{"value":98563},{"value":98563},{"value":37},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":1},{"value":5089980184},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":11947658104},{"value":0},{"value":5261566752},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":6138048384},"sp":{"value":6138048352},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":58},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":58},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":58},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"ausm_messenger_for_buffer_disposal","threadState":{"x":[{"value":14},{"value":4756418499},{"value":0},{"value":6106509427},{"value":4756418464},{"value":34},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":6106509312},{"value":0},{"value":5629364472},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":11622329452},"cpsr":{"value":2147487744},"fp":{"value":6106509184},"sp":{"value":6106509152},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":15468,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":224,"imageIndex":58},{"imageOffset":15544,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":32,"imageIndex":58},{"imageOffset":32596,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":58},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":56},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1594748,"imageIndex":4},{"imageOffset":1630184,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":6112243472},{"value":6112243488},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6112243456},"sp":{"value":6112243408},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"GThreadManager","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":10000000},{"value":0},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":10},{"value":10},{"value":0},{"value":34121984},{"value":146552805388757248},{"value":334},{"value":4729061095673708888},{"value":0},{"value":0},{"value":6122564048},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6122564016},"sp":{"value":6122563968},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":103124,"imageIndex":30},{"imageOffset":100252,"imageIndex":30},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51540,"symbol":"sleep","symbolLocation":52,"imageIndex":56},{"imageOffset":1303464,"imageIndex":4},{"imageOffset":1833920,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}],"threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":30},{"value":0},{"value":52},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":16387},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":4729061095673708888},{"value":0},{"value":6124859200},{"value":6124859216},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":1610616832},"fp":{"value":6124859184},"sp":{"value":6124859136},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}}},{"id":{{TID}},"name":"ace_rp_queue","threadState":{"x":[{"value":4},{"value":0},{"value":96},{"value":18446726483666796544},{"value":1},{"value":9},{"value":0},{"value":0},{"value":1},{"value":4288835200},{"value":0},{"value":0},{"value":245924797968388479},{"value":245907201487374756},{"value":1937408},{"value":4672307200},{"value":271},{"value":28356952484},{"value":0},{"value":5261974272},{"value":0},{"value":65536},{"value":5261974808},{"value":5794611200},{"value":0},{"value":3435973837},{"value":214748364},{"value":1717986919},{"value":279}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4611774252},"cpsr":{"value":2684358656},"fp":{"value":6129446624},"sp":{"value":6129446544},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834389484},"far":{"value":0}},"frames":[{"imageOffset":85996,"symbol":"sem_wait","symbolLocation":8,"imageIndex":44},{"imageOffset":612140,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"GVoiceUtil","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":0},{"value":0},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":0},{"value":0},{"value":0},{"value":0},{"value":334},{"value":8691416560},{"value":0},{"value":0},{"value":6132887424},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6132887408},"sp":{"value":6132887360},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":56},{"imageOffset":176195540,"imageIndex":0},{"imageOffset":174470112,"symbol":"ApolloTVE::CSysThread::GSysThreadProc(void*)","symbolLocation":24,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"GVoiceCapture","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":3543824036068086856},{"value":6135181536},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":505408740453399524},{"value":24000000},{"value":657586},{"value":0},{"value":0},{"value":334},{"value":6135181312},{"value":0},{"value":0},{"value":6135172864},{"value":5794389976},{"value":4},{"value":6135172928},{"value":5794502619},{"value":1},{"value":0},{"value":5794491536},{"value":4}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6135172848},"sp":{"value":6135172800},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":56},{"imageOffset":175859080,"imageIndex":0},{"imageOffset":174470112,"symbol":"ApolloTVE::CSysThread::GSysThreadProc(void*)","symbolLocation":24,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"GVoiceCdnv","threadState":{"x":[{"value":4},{"value":0},{"value":1},{"value":1},{"value":0},{"value":20000000},{"value":0},{"value":18446726482597246976},{"value":8664747920,"symbolLocation":0,"symbol":"clock_sem"},{"value":3},{"value":17},{"value":4294967293},{"value":3072},{"value":0},{"value":3072},{"value":13194139536384},{"value":334},{"value":8691413816},{"value":0},{"value":0},{"value":6135754544},{"value":4755860704},{"value":4755860504},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7092537388},"cpsr":{"value":2684358656},"fp":{"value":6135754528},"sp":{"value":6135754480},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834330120},"far":{"value":0}},"frames":[{"imageOffset":26632,"symbol":"__semwait_signal","symbolLocation":8,"imageIndex":44},{"imageOffset":51244,"symbol":"nanosleep","symbolLocation":220,"imageIndex":56},{"imageOffset":51012,"symbol":"usleep","symbolLocation":68,"imageIndex":56},{"imageOffset":177471172,"imageIndex":0},{"imageOffset":177454692,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"Log work queue","threadState":{"x":[{"value":14},{"value":6140465152},{"value":1},{"value":0},{"value":15536504448},{"value":0},{"value":18446744072631617535},{"value":18446726482597246976},{"value":0},{"value":12},{"value":13},{"value":104},{"value":6140461056},{"value":3739174925},{"value":1},{"value":6140461056},{"value":18446744073709551580},{"value":8691361248},{"value":0},{"value":6040470016},{"value":6040470056},{"value":6120271872},{"value":0},{"value":0},{"value":6040666624},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7371846036},"cpsr":{"value":2147487744},"fp":{"value":6120271696},"sp":{"value":6120271664},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":19763604,"symbol":"WTF::Detail::CallableWrapper<IPC::StreamConnectionWorkQueue::startProcessingThread()::$_0, void>::call()","symbolLocation":52,"imageIndex":59},{"imageOffset":995056,"symbol":"WTF::Thread::entryPoint(WTF::Thread::NewThreadContext*)","symbolLocation":356,"imageIndex":60},{"imageOffset":1009320,"symbol":"WTF::wtfThreadEntryPoint(void*)","symbolLocation":16,"imageIndex":60},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"com.apple.CoreMotion.MotionThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":811452466200576},{"value":0},{"value":811452466200576},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":188931},{"value":9472},{"value":40681930237184},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":811452466200576},{"value":0},{"value":811452466200576},{"value":21592279046},{"value":6131161368},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6131161216},"sp":{"value":6131161136},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":44},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":44},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":44},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":49},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":49},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":49},{"imageOffset":912868,"symbol":"CFRunLoopRun","symbolLocation":64,"imageIndex":49},{"imageOffset":91516,"imageIndex":61},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":16359829120},{"value":4522627776},{"value":0},{"value":1152921504606846976},{"value":0},{"value":77319},{"value":18446744073709551615},{"value":5144738768},{"value":5144739944},{"value":1},{"value":4294967158},{"value":3},{"value":4294967158},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":4812205296},{"value":4812205232},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6438809344},"sp":{"value":6438809328},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":156801380,"imageIndex":0},{"imageOffset":160709056,"imageIndex":0},{"imageOffset":160732572,"imageIndex":0},{"imageOffset":162816540,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":0},{"value":0},{"value":4555960720},{"value":1912},{"value":0},{"value":197127},{"value":18446744073709551615},{"value":5139802304},{"value":5139809496},{"value":18446744073709551600},{"value":658997},{"value":1},{"value":658997},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":4812195216},{"value":4812195152},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":6439120640},"sp":{"value":6439120624},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":156801380,"imageIndex":0},{"imageOffset":160709056,"imageIndex":0},{"imageOffset":160732572,"imageIndex":0},{"imageOffset":162816540,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":16359829312},{"value":4522627776},{"value":4555960720},{"value":3458764513820540928},{"value":0},{"value":197891},{"value":18446744073709551615},{"value":5140189584},{"value":5140190528},{"value":118528},{"value":0},{"value":118528},{"value":509073883778816},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":4812202256},{"value":4812202192},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":15249682176},"sp":{"value":15249682160},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":156801380,"imageIndex":0},{"imageOffset":160709056,"imageIndex":0},{"imageOffset":160732572,"imageIndex":0},{"imageOffset":162816540,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"AGCThread","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":4294967295},{"value":0},{"value":0},{"value":4555960720},{"value":1912},{"value":0},{"value":198403},{"value":18446744073709551615},{"value":5140593344},{"value":5140598088},{"value":1},{"value":589842},{"value":2},{"value":589842},{"value":18446744073709551580},{"value":8691414312},{"value":0},{"value":4812202416},{"value":4812202352},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":15250468608},"sp":{"value":15250468592},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":156801380,"imageIndex":0},{"imageOffset":160709056,"imageIndex":0},{"imageOffset":160732572,"imageIndex":0},{"imageOffset":162816540,"imageIndex":0},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"com.apple.UIKit.inProcessAnimationManager","threadState":{"x":[{"value":14},{"value":18446744073709551615},{"value":17179869187},{"value":1},{"value":17179869187},{"value":3},{"value":17179869187},{"value":3},{"value":219151},{"value":18446744073709551615},{"value":8973489792},{"value":15},{"value":9964928},{"value":0},{"value":8664751144,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_dispatch_semaphore"},{"value":8664751144,"symbolLocation":0,"symbol":"OBJC_CLASS_$_OS_dispatch_semaphore"},{"value":18446744073709551580},{"value":8691400048},{"value":0},{"value":15550109376},{"value":15550109312},{"value":18446744073709551615},{"value":15550583616},{"value":15550109312},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7880672272},"cpsr":{"value":1610616832},"fp":{"value":15398890576},"sp":{"value":15398890560},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306640},"far":{"value":0}},"frames":[{"imageOffset":3152,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":13328,"symbol":"_dispatch_sema4_wait","symbolLocation":28,"imageIndex":55},{"imageOffset":15008,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":132,"imageIndex":55},{"imageOffset":4039160,"imageIndex":47},{"imageOffset":4039088,"imageIndex":47},{"imageOffset":263620,"imageIndex":47},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"ace_cs2","threadState":{"x":[{"value":4},{"value":0},{"value":0},{"value":0},{"value":6104788464},{"value":9},{"value":36},{"value":18446726482597246976},{"value":4613599232},{"value":2},{"value":6104788444},{"value":0},{"value":166},{"value":13194139536384},{"value":9216},{"value":39582418609152},{"value":93},{"value":50522360064},{"value":0},{"value":4803588352},{"value":4803588576},{"value":4613939056},{"value":2835},{"value":3226763252},{"value":241638085},{"value":536870912},{"value":5},{"value":6104788480},{"value":248706189}],"flavor":"ARM_THREAD_STATE64","lr":{"value":4611614628},"cpsr":{"value":2684358656},"fp":{"value":6104788704},"sp":{"value":6104788464},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834337136},"far":{"value":0}},"frames":[{"imageOffset":33648,"symbol":"__select","symbolLocation":8,"imageIndex":44},{"imageOffset":452516,"imageIndex":4},{"imageOffset":868292,"imageIndex":4},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"PingThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":1483563308417024},{"value":0},{"value":1483563308417024},{"value":2},{"value":4294967295},{"value":0},{"value":0},{"value":2},{"value":0},{"value":0},{"value":345419},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8691416560},{"value":0},{"value":4294967295},{"value":2},{"value":1483563308417024},{"value":0},{"value":1483563308417024},{"value":21592279046},{"value":6421011880},{"value":8589934592},{"value":18446744073709550527},{"value":11145936896,"symbolLocation":0,"symbol":"_libkernel_string_functions"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":9834320652},"cpsr":{"value":4096},"fp":{"value":6421011728},"sp":{"value":6421011648},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834306772},"far":{"value":0}},"frames":[{"imageOffset":3284,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":44},{"imageOffset":17164,"symbol":"mach_msg2_internal","symbolLocation":76,"imageIndex":44},{"imageOffset":16940,"symbol":"mach_msg_overwrite","symbolLocation":424,"imageIndex":44},{"imageOffset":16504,"symbol":"mach_msg","symbolLocation":24,"imageIndex":44},{"imageOffset":414580,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":49},{"imageOffset":193296,"symbol":"__CFRunLoopRun","symbolLocation":1188,"imageIndex":49},{"imageOffset":189772,"symbol":"_CFRunLoopRunSpecificWithOptions","symbolLocation":532,"imageIndex":49},{"imageOffset":44272,"symbol":"-[NSRunLoop(NSRunLoop) runMode:beforeDate:]","symbolLocation":212,"imageIndex":53},{"imageOffset":62204,"symbol":"-[NSRunLoop(NSRunLoop) run]","symbolLocation":64,"imageIndex":53},{"imageOffset":855228,"symbol":"+[GSDKPing pingThreadEntryPoint:]","symbolLocation":204,"imageIndex":12},{"imageOffset":583956,"symbol":"__NSThread__start__","symbolLocation":732,"imageIndex":53},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":16237703168},{"value":514091},{"value":16237166592},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":16237703168},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"name":"MSDK-HTTP-34","threadState":{"x":[{"value":16192565248},{"value":303003},{"value":16192028672},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":16192565248},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}},"frames":[]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6298333184},{"value":359307},{"value":6297796608},{"value":0},{"value":409603},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6298333184},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"name":"GThreadProcess","threadState":{"x":[{"value":4},{"value":0},{"value":44825600},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6298904872},{"value":0},{"value":34121984},{"value":146552805388757250},{"value":146552805388757250},{"value":34121984},{"value":0},{"value":146552805388757248},{"value":305},{"value":4729061095673708888},{"value":0},{"value":5531254360},{"value":5531254424},{"value":6298906848},{"value":0},{"value":0},{"value":44825600},{"value":44825600},{"value":44826112},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6298904992},"sp":{"value":6298904848},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":103480,"imageIndex":30},{"imageOffset":102216,"imageIndex":30},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"name":"GThreadProcess","threadState":{"x":[{"value":260},{"value":0},{"value":44825600},{"value":0},{"value":0},{"value":65704},{"value":0},{"value":0},{"value":6313699624},{"value":0},{"value":34121984},{"value":146552805388757250},{"value":146552805388757250},{"value":34121984},{"value":0},{"value":146552805388757248},{"value":305},{"value":4729061095673708888},{"value":0},{"value":5531254360},{"value":5531254424},{"value":6313701600},{"value":0},{"value":0},{"value":44825600},{"value":44825601},{"value":44825856},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6313699744},"sp":{"value":6313699600},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":103480,"imageIndex":30},{"imageOffset":102216,"imageIndex":30},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]},{"id":{{TID}},"frames":[],"threadState":{"x":[{"value":6320058368},{"value":366499},{"value":6319521792},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6320058368},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":8499112120},"far":{"value":0}}},{"id":{{TID}},"name":"JavaScriptCore libpas scavenger","threadState":{"x":[{"value":260},{"value":0},{"value":184781824},{"value":0},{"value":0},{"value":160},{"value":9},{"value":999998960},{"value":6102478504},{"value":0},{"value":153600},{"value":659706976819202},{"value":659706976819202},{"value":153600},{"value":0},{"value":659706976819200},{"value":305},{"value":8691416304},{"value":0},{"value":5901445184},{"value":5901445248},{"value":6102479072},{"value":999998960},{"value":9},{"value":184781824},{"value":184785921},{"value":184786176},{"value":0},{"value":8668708864,"symbolLocation":0,"symbol":"WTF::globalMaxQOSclass"}],"flavor":"ARM_THREAD_STATE64","lr":{"value":8499120968},"cpsr":{"value":1610616832},"fp":{"value":6102478624},"sp":{"value":6102478480},"esr":{"value":1442840704,"description":"(Syscall)"},"pc":{"value":9834329576},"far":{"value":0}},"frames":[{"imageOffset":26088,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":44},{"imageOffset":11080,"symbol":"_pthread_cond_wait","symbolLocation":980,"imageIndex":45},{"imageOffset":29667316,"symbol":"scavenger_thread_main","symbolLocation":1632,"imageIndex":60},{"imageOffset":17464,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":45},{"imageOffset":2252,"symbol":"thread_start","symbolLocation":8,"imageIndex":45}]}],
  "usedImages" : [
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4365516800}},
    "size" : 204603392,
    "uuid" : "{{SLICE_UUID}}",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/cod",
    "name" : "cod"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4607901696}},
    "size" : 1556480,
    "uuid" : "9e906efb-df5a-3cb6-862e-fde98b81d7d6",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/LineSDK.framework\/LineSDK",
    "name" : "LineSDK"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4606181376}},
    "size" : 65536,
    "uuid" : "042997a5-1601-37e0-92d9-5304f4c81262",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAgeRange.framework\/MSDKPIXAgeRange",
    "name" : "MSDKPIXAgeRange"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4610195456}},
    "size" : 344064,
    "uuid" : "ba9f446f-4357-3638-8b1c-420329ab4ec7",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKLoginKit.framework\/FBSDKLoginKit",
    "name" : "FBSDKLoginKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4611162112}},
    "size" : 2719744,
    "uuid" : "012c9348-ff37-38ec-8089-07fdf5e10a07",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/anogs.framework\/anogs",
    "name" : "anogs"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4614209536}},
    "size" : 311296,
    "uuid" : "ed95e02a-12fd-36d3-8149-e39652bae555",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/HelpshiftX.framework\/HelpshiftX",
    "name" : "HelpshiftX"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4614864896}},
    "size" : 344064,
    "uuid" : "0e1ddd7d-b20d-39d3-a484-7b03f479cb53",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKGamingServicesKit.framework\/FBSDKGamingServicesKit",
    "name" : "FBSDKGamingServicesKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4607246336}},
    "size" : 81920,
    "uuid" : "929a6cbc-e64d-3736-8945-2d8b2c71ff7a",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXGameCenter.framework\/MSDKPIXGameCenter",
    "name" : "MSDKPIXGameCenter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4606361600}},
    "size" : 65536,
    "uuid" : "8f08fc0f-9cd9-3599-bfa4-e8d985e7e30d",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXUNO.framework\/MSDKPIXUNO",
    "name" : "MSDKPIXUNO"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4616028160}},
    "size" : 49152,
    "uuid" : "d939e334-68c3-305d-b1bd-f2659ac15200",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXSystem.framework\/MSDKPIXSystem",
    "name" : "MSDKPIXSystem"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4616175616}},
    "size" : 507904,
    "uuid" : "6f5c6104-160b-3e92-8978-d59ba01ec260",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/TDataMaster.framework\/TDataMaster",
    "name" : "TDataMaster"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4617142272}},
    "size" : 32768,
    "uuid" : "25026fbe-1e50-3483-8da1-2ad9b09c31df",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightAdapter.framework\/CrashSightAdapter",
    "name" : "CrashSightAdapter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4617240576}},
    "size" : 1245184,
    "uuid" : "7fea6069-6037-3772-b440-b1b93a278f91",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GPM_dylib.framework\/GPM_dylib",
    "name" : "GPM_dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4619517952}},
    "size" : 49152,
    "uuid" : "53220543-4e6d-3097-a8c8-c8e135aeeee3",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXApple.framework\/MSDKPIXApple",
    "name" : "MSDKPIXApple"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4619649024}},
    "size" : 32768,
    "uuid" : "e564426d-cabd-3e48-b7b0-9a1603ae2f81",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/TDMASA.framework\/TDMASA",
    "name" : "TDMASA"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4619730944}},
    "size" : 32768,
    "uuid" : "dc00db9a-27ab-3bb3-8bad-bb2b26c4b824",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/videotexture.framework\/videotexture",
    "name" : "videotexture"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4619812864}},
    "size" : 458752,
    "uuid" : "de98ceaa-1e6b-303a-83a0-76e4938755c7",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXWebView.framework\/MSDKPIXWebView",
    "name" : "MSDKPIXWebView"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4620632064}},
    "size" : 688128,
    "uuid" : "e5a358a8-42c7-3584-9abe-b1a3e0fb4ce6",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GCloudCore.framework\/GCloudCore",
    "name" : "GCloudCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4621959168}},
    "size" : 245760,
    "uuid" : "ac9592c9-aa67-35fb-9e23-9f3ede984913",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBAEMKit.framework\/FBAEMKit",
    "name" : "FBAEMKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4622581760}},
    "size" : 2768896,
    "uuid" : "377cda1b-dda4-3c2f-bcf6-d1aa207f9fd7",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXCore.framework\/MSDKPIXCore",
    "name" : "MSDKPIXCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4628938752}},
    "size" : 65536,
    "uuid" : "424ec5f4-b620-3004-9918-24067e016ae6",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXLine.framework\/MSDKPIXLine",
    "name" : "MSDKPIXLine"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4629168128}},
    "size" : 1048576,
    "uuid" : "90b8c4a8-9ab8-3513-8f33-6625c8063ff2",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSight.framework\/CrashSight",
    "name" : "CrashSight"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4631248896}},
    "size" : 32768,
    "uuid" : "7718cc27-15ea-3c2f-8ab2-82a57b649047",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PluginCrosCurl.framework\/PluginCrosCurl",
    "name" : "PluginCrosCurl"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4631347200}},
    "size" : 1884160,
    "uuid" : "10c9140a-3444-3f74-882a-e3c7b595da40",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/LineSDKObjC.framework\/LineSDKObjC",
    "name" : "LineSDKObjC"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4634198016}},
    "size" : 163840,
    "uuid" : "8f65166a-ca6f-3702-a474-83552ca76429",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAdapter.framework\/MSDKPIXAdapter",
    "name" : "MSDKPIXAdapter"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4634591232}},
    "size" : 32768,
    "uuid" : "7387c47a-8dc1-3f4c-8dfc-c5d9e7ad06c5",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXTDM.framework\/MSDKPIXTDM",
    "name" : "MSDKPIXTDM"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4634689536}},
    "size" : 32768,
    "uuid" : "f1581592-5fc1-3598-b66d-6e74fedd4452",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPolicy.framework\/MSDKPolicy",
    "name" : "MSDKPolicy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4634771456}},
    "size" : 65536,
    "uuid" : "57c4f8c7-877f-380e-8ae5-5ab8d6b41bd5",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXAppsFlyer.framework\/MSDKPIXAppsFlyer",
    "name" : "MSDKPIXAppsFlyer"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4634984448}},
    "size" : 1245184,
    "uuid" : "7e56c197-9bc6-3bc0-97b8-e87abaabd89c",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKCoreKit.framework\/FBSDKCoreKit",
    "name" : "FBSDKCoreKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4638392320}},
    "size" : 278528,
    "uuid" : "5cb7f8ab-b746-3481-8a0b-bc2738410394",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKShareKit.framework\/FBSDKShareKit",
    "name" : "FBSDKShareKit"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4639211520}},
    "size" : 18989056,
    "uuid" : "a9ea6186-0312-3b3e-af05-37bc346abb8a",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/GCloud.framework\/GCloud",
    "name" : "GCloud"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4659331072}},
    "size" : 393216,
    "uuid" : "f978a56e-baf9-3390-bda9-cb8e729ff593",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/enq_transceiver_dy.framework\/enq_transceiver_dy",
    "name" : "enq_transceiver_dy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4660051968}},
    "size" : 49152,
    "uuid" : "97f6fa50-d229-3692-a679-1b9f394db5da",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightPlugin.framework\/CrashSightPlugin",
    "name" : "CrashSightPlugin"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4660183040}},
    "size" : 32768,
    "uuid" : "f633fac4-a6b2-30e8-8dfb-c71fa6061c8c",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/APMDeviceInfoSupport_dylib.framework\/APMDeviceInfoSupport_dylib",
    "name" : "APMDeviceInfoSupport_dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4660264960}},
    "size" : 98304,
    "uuid" : "8bfbc769-da7f-322e-bd70-2edbdc26c1b0",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXFacebook.framework\/MSDKPIXFacebook",
    "name" : "MSDKPIXFacebook"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4660559872}},
    "size" : 409600,
    "uuid" : "b2dbfcaf-c010-3f32-b3fa-7622cab07a78",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/crosCurl.framework\/crosCurl",
    "name" : "crosCurl"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4661084160}},
    "size" : 147456,
    "uuid" : "c6b8e6ad-fab0-323c-a6e6-82ccc9111589",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPopup.framework\/MSDKPopup",
    "name" : "MSDKPopup"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4661362688}},
    "size" : 3686400,
    "uuid" : "d1db61c9-0b90-3667-8f4c-1ddb0b80514f",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/PixVideo.framework\/PixVideo",
    "name" : "PixVideo"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4667768832}},
    "size" : 32768,
    "uuid" : "360ac7c3-91c9-3290-917c-690349e3d9c5",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/MSDKPIXSensitivity.framework\/MSDKPIXSensitivity",
    "name" : "MSDKPIXSensitivity"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4667850752}},
    "size" : 425984,
    "uuid" : "2e2fc0e2-16ac-3955-af09-cc66a0e34d39",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/AppsFlyerLib.framework\/AppsFlyerLib",
    "name" : "AppsFlyerLib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4668751872}},
    "size" : 98304,
    "uuid" : "ec39b0c5-d667-3a5a-b236-2200bf36de98",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/CrashSightCore.framework\/CrashSightCore",
    "name" : "CrashSightCore"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4669014016}},
    "size" : 770048,
    "uuid" : "f89ab06a-b8a9-3bd9-bea0-f60fd1f5bfdf",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/kgvmp_dy.framework\/kgvmp_dy",
    "name" : "kgvmp_dy"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : {{IMG_BASE:4670291968}},
    "size" : 65536,
    "uuid" : "6ed9543d-d000-3c65-a476-da0b5450fce2",
    "path" : "\/private\/var\/containers\/Bundle\/Application\/{{APP_CONTAINER}}\/cod.app\/Frameworks\/FBSDKCoreKit_Basics.framework\/FBSDKCoreKit_Basics",
    "name" : "FBSDKCoreKit_Basics"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:4746870784}},
    "size" : 49152,
    "uuid" : "004ce93c-f142-3d68-b3c3-30c6efef4d65",
    "path" : "\/private\/preboot\/Cryptexes\/OS\/usr\/lib\/libobjc-trampolines.dylib",
    "name" : "libobjc-trampolines.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:9834303488}},
    "size" : 244512,
    "uuid" : "18665b3f-6d51-33ab-b9e9-63062200ec42",
    "path" : "\/usr\/lib\/system\/libsystem_kernel.dylib",
    "name" : "libsystem_kernel.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:8499109888}},
    "size" : 50416,
    "uuid" : "34b44744-bc64-386e-ab90-eee86b23ac46",
    "path" : "\/usr\/lib\/system\/libsystem_pthread.dylib",
    "name" : "libsystem_pthread.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6906294272}},
    "size" : 4132544,
    "uuid" : "8f1e0b3f-add6-3710-a790-009333597ab4",
    "path" : "\/System\/Library\/Frameworks\/QuartzCore.framework\/QuartzCore",
    "name" : "QuartzCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6992625664}},
    "size" : 39073344,
    "uuid" : "0d94422f-fe7c-302e-b896-3bc5873c0cfc",
    "path" : "\/System\/Library\/PrivateFrameworks\/UIKitCore.framework\/UIKitCore",
    "name" : "UIKitCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:11540299776}},
    "size" : 8640,
    "uuid" : "26fab814-4c8f-3a06-b45e-cba271020dc4",
    "path" : "\/System\/Library\/PrivateFrameworks\/UpdateCycle.framework\/UpdateCycle",
    "name" : "UpdateCycle"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6895890432}},
    "size" : 5884480,
    "uuid" : "101eb2f1-1915-34a0-8bc9-631d03753b84",
    "path" : "\/System\/Library\/Frameworks\/CoreFoundation.framework\/CoreFoundation",
    "name" : "CoreFoundation"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:9676554240}},
    "size" : 34752,
    "uuid" : "411165e2-ee8e-380e-b254-9977273971e3",
    "path" : "\/System\/Library\/PrivateFrameworks\/GraphicsServices.framework\/GraphicsServices",
    "name" : "GraphicsServices"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6841585664}},
    "size" : 676992,
    "uuid" : "0f8d35b6-556f-3e34-8eaa-80ab54047dc5",
    "path" : "\/usr\/lib\/dyld",
    "name" : "dyld"
  },
  {
    "size" : 0,
    "source" : "A",
    "base" : {{IMG_BASE:0}},
    "uuid" : "00000000-0000-0000-0000-000000000000"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:6848249856}},
    "size" : 15244480,
    "uuid" : "73841aa3-bfdd-322d-8dc2-e5185a14dee1",
    "path" : "\/System\/Library\/Frameworks\/Foundation.framework\/Foundation",
    "name" : "Foundation"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7155339264}},
    "size" : 592508,
    "uuid" : "be42c221-2eb0-3636-aef5-9cedc8b1f656",
    "path" : "\/usr\/lib\/libc++.1.dylib",
    "name" : "libc++.1.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7880658944}},
    "size" : 288256,
    "uuid" : "49c0cd3e-a696-3b11-ba92-5755f0c3c6e3",
    "path" : "\/usr\/lib\/system\/libdispatch.dylib",
    "name" : "libdispatch.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7092486144}},
    "size" : 521728,
    "uuid" : "ff429821-80de-3a68-99cb-0b2e707e8d48",
    "path" : "\/usr\/lib\/system\/libsystem_c.dylib",
    "name" : "libsystem_c.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7253114880}},
    "size" : 3868544,
    "uuid" : "3ae849fe-8a7d-388c-86ef-64dedb9fc5c6",
    "path" : "\/System\/Library\/Frameworks\/CFNetwork.framework\/CFNetwork",
    "name" : "CFNetwork"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:11622313984}},
    "size" : 167968,
    "uuid" : "5dd354fb-a86f-3732-8f36-a88736414f79",
    "path" : "\/System\/Library\/PrivateFrameworks\/caulk.framework\/caulk",
    "name" : "caulk"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7352082432}},
    "size" : 24644064,
    "uuid" : "c39bd22c-3475-38af-91bd-0b7574081011",
    "path" : "\/System\/Library\/Frameworks\/WebKit.framework\/WebKit",
    "name" : "WebKit"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7256985600}},
    "size" : 32251488,
    "uuid" : "f7906028-1c6d-3b4c-bd93-78c196c83a83",
    "path" : "\/System\/Library\/Frameworks\/JavaScriptCore.framework\/JavaScriptCore",
    "name" : "JavaScriptCore"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : {{IMG_BASE:7316545536}},
    "size" : 4551488,
    "uuid" : "33533ca9-f9fb-3516-af0a-03c1b9469f97",
    "path" : "\/System\/Library\/Frameworks\/CoreMotion.framework\/CoreMotion",
    "name" : "CoreMotion"
  }
],
  "sharedCache" : {
  "base" : {{IMG_BASE:6840418304}},
  "size" : 5383520256,
  "uuid" : "a0faea75-70ff-3a53-8881-bc6fe2b6c70b"
},
  "vmSummary" : "ReadOnly portion of Libraries: Total=2.3G resident=0K(0%) swapped_out_or_unallocated=2.3G(100%)\nWritable regions: Total=4.0G written=2232K(0%) resident=2152K(0%) swapped_out=80K(0%) unallocated=4.0G(100%)\n\n                                VIRTUAL   REGION \nREGION TYPE                        SIZE    COUNT (non-coalesced) \n===========                     =======  ======= \nActivity Tracing                   256K        1 \nAttributeGraph Data               1024K        1 \nAudio                               64K        1 \nCG raster data                     112K        2 \nColorSync                           16K        1 \nCoreAnimation                      288K       12 \nFoundation                         208K        2 \nImage IO                          4112K        2 \nJS VM Gigacage (reserved)          2.0G        1         reserved VM address space (unallocated)\nKernel Alloc Once                   32K        1 \nMALLOC                             1.1G      284 \nMALLOC guard page                 3328K        4 \nMach message                      3248K      203 \nMemory Tag 22                     64.0M        1 \nSQLite page cache                 1408K       11 \nSTACK GUARD                        736K       46 \nStack                             23.9M       46 \nVM_ALLOCATE                      610.6M     5681 \nVM_ALLOCATE (reserved)            22.5M        8         reserved VM address space (unallocated)\nWebKit Malloc                    224.1M        8 \nWebKit Malloc (reserved)          64.0M        1         reserved VM address space (unallocated)\n__AUTH                            12.0M      984 \n__AUTH_CONST                     127.0M     1433 \n__CTF                               824        1 \n__DATA                            79.2M     1428 \n__DATA_CONST                      54.5M     1446 \n__DATA_DIRTY                      12.3M     1249 \n__FONT_DATA                        2352        1 \n__LINKEDIT                       201.7M       45 \n__OBJC_RO                         84.8M        1 \n__OBJC_RW                         3182K        1 \n__TEXT                             2.1G     1503 \n__TPRO_CONST                       128K        2 \nmapped file                      432.7M      266 \npage table in kernel              2152K        1 \nshared memory                       80K        4 \n===========                     =======  ======= \nTOTAL                              7.1G    14682 \nTOTAL, minus reserved VM space     5.1G    14682 \n",
  "legacyInfo" : {
  "threadTriggered" : {
    "queue" : "com.apple.main-thread"
  }
},
  "logWritingSignature" : "{{LOG_SIGNATURE}}",
  "roots_installed" : 0,
  "bug_type" : "309",
  "trmStatus" : 1,
  "sandboxProfileName" : "container",
  "trialInfo" : {
  "rollouts" : [
    {
      "rolloutId" : "6434420a89ec2e0a7a38bf5a",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000011
    },
    {
      "rolloutId" : "64628732bf2f5257dedc8988",
      "factorPackIds" : [

      ],
      "deploymentId" : 240000001
    }
  ],
  "experiments" : [
    {
      "treatmentId" : "d5c127b8-b13e-42a1-acf5-c483124a1bb5",
      "experimentId" : "66b1602abe27b2208fd291ba",
      "deploymentId" : 400000022
    },
    {
      "treatmentId" : "582596be-1d4a-408d-901b-5b311c006a4a",
      "experimentId" : "65f31ccb74b6f500a45abda4",
      "deploymentId" : 400000026
    }
  ]
}
}

"""#

}