CHEADER = SwiftHalWrapper.h

SRCS = $(wildcard *.swift)
OBJS = $(SRCS:.swift=.o)

FLAGS = -module-name SwiftIO -target thumbv7em-none--eabi -target-cpu cortex-m7 -target-fpu fpv5-dp-d16 -float-abi hard -parse-as-library -Osize -static-stdlib -function-sections -data-sections -no-link-objc-runtime -import-objc-header $(CHEADER) -I . 

libSwiftIO.a: $(OBJS) SwiftIO.swiftmodule
	$(AR) -rcs libSwiftIO.a $(OBJS)

$(OBJS): 
	$(SWIFTC) -c $(FLAGS) -I $(STDDIR) $(SRCS)

SwiftIO.swiftmodule: 
	$(SWIFTC) -emit-module $(FLAGS) -I $(STDDIR) $(SRCS)

install: libSwiftIO.a SwiftIO.swiftmodule
	rm -f $(INSTDIR)/*.a $(INSTDIR)/*.swiftmodule
	cp libSwiftIO.a $(INSTDIR)
	cp SwiftIO.swiftmodule $(INSTDIR)


.PHONY: clean
clean:
	rm -f *.swiftdoc *.swiftmodule *.o *.a
