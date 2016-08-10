#include "Timer.h"
#include "logger.h"
configuration UsigTestC { }
implementation {

	components MainC;

	components BootInfoC;

	components new TimerWatchdogC(5*1024UL);

	components new BlinkyC(1024, 50);

	components ActiveMessageC as Radio;

	components new Boot2SplitControlC("slbt", "rdo");
	Boot2SplitControlC.Boot -> MainC.Boot;
	Boot2SplitControlC.SplitControl -> Radio;

}
