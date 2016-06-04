#ifndef PTL_SERIALIZER_H__
#define PTL_SERIALIZER_H__

namespace base_logic {
// ptl

class PtlValueSerializer:public ValueSerializer {
public:
	PtlValueSerializer();
	virtual ~PtlValueSerializer();
public:
	virtual bool Serialize(const Value& root);
private:


};
}
#endif
