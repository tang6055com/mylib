THRIFT_INC=/usr/local/thrift/include/
THRIFT_DIR=/usr/local/thrift/include/thrift/
LIB_DIR=/usr/local/thrift/lib/
BOOST_DIR=/usr/local/boost/include/
INCLUDE_DIR=-I./ \
						-I./gen-cpp \
					 	-I${BOOST_DIR} \
						-I${THRIFT_INC} \
						-I${THRIFT_DIR} 

SOURCEDIR=./gen-cpp/


ALL:libhbaseclient.a clean

libhbaseclient.a:Hbase.o Hbase_constants.o Hbase_types.o hbase_conn_pool.o hbase_accessor.o
	ar rc ./hbaseclientlib/libhbaseclient.a Hbase.o Hbase_constants.o Hbase_types.o hbase_conn_pool.o hbase_accessor.o

Hbase.o:${SOURCEDIR}/Hbase.cpp ${SOURCEDIR}/Hbase.h
	g++ -c -L${LIB_DIR} -lthrift ${INCLUDE_DIR} ${SOURCEDIR}/Hbase.cpp

Hbase_constants.o:${SOURCEDIR}/Hbase_constants.cpp ${SOURCEDIR}/Hbase_constants.h
	g++ -c -L${LIB_DIR} -lthrift ${INCLUDE_DIR} ${SOURCEDIR}/Hbase_constants.cpp

Hbase_types.o:${SOURCEDIR}/Hbase_types.cpp ${SOURCEDIR}/Hbase_types.h
	g++ -c -L${LIB_DIR} -lthrift ${INCLUDE_DIR} ${SOURCEDIR}/Hbase_types.cpp

hbase_conn_pool.o:hbase_conn_pool.cc hbase_conn_pool.h
	g++ -c -L${LIB_DIR} -lthrift ${INCLUDE_DIR} hbase_conn_pool.cc

hbase_accessor.o:hbase_accessor.cc hbase_accessor.h
	g++ -c -L${LIB_DIR} -lthrift ${INCLUDE_DIR} hbase_accessor.cc

clean:
	rm -f ./*.o
