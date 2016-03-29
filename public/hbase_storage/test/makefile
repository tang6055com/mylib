THRIFT_INC=/usr/local/thrift/include/
THRIFT_DIR=/usr/local/thrift/include/thrift/
LIB_DIR=/usr/local/thrift/lib/
BOOST_DIR=/usr/local/boost/include/
INCLUDE_DIR=-I./ \
						-I../ \
						-I../gen-cpp \
					 	-I${BOOST_DIR} \
						-I${THRIFT_INC} \
						-I${THRIFT_DIR} 

SOURCEDIR=../gen-cpp/


ALL:hbasetest clean

hbasetest:test.o
	g++ -o hbasetest test.o ../hbaseclientlib/libhbaseclient.a ${INCLUDE_DIR} -L${LIB_DIR} -lthrift

test.o:test.cc
	g++ -c -L${LIB_DIR} -lthrift ${INCLUDE_DIR} test.cc

clean:
	rm -f ./*.o
