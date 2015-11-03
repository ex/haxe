
#include <string>
#include <vector>

class DummyDataCpp
{
public:
	int number;
	std::string string;

	DummyDataCpp()
	{
		number = (int)( 1000000 * rand() );
		string = "DEADBABE";
	}
};

class DummyCpp
{
public:
	DummyCpp()
	{
		m_data = new std::vector<DummyDataCpp*>();

		if (!false)
		{
			DummyDataCpp *dummyData = NULL;
			for ( int k = 1; k < 15; k++ )
			{
				dummyData = new DummyDataCpp();
				m_data->push_back( dummyData );
				m_counter += (m_counter % 2 == 0) ? dummyData->number : -dummyData->number;
			}
		}
	}

private:
	std::vector<DummyDataCpp*> *m_data;
	static int m_counter;
};

#if 0
int k = 1000000000;
while (k--) {}

tmp = ::__time_stamp();

std::vector<DummyCpp*> *dummiesCpp = new std::vector<DummyCpp*>();
DummyCpp *dummyCpp = NULL;

for (int k = 1; k < 400000; k++)
{
	dummyCpp = new DummyCpp();
	dummiesCpp->push_back(dummyCpp);
	if (k % 50000 == 0)
	{
		::String tmp7 = (HX_HCSTRING("k: ", "\xd1", "\x63", "\x51", "\x00") + k);
		Dynamic tmp8 = hx::SourceInfo(HX_HCSTRING("Main.hx", "\x05", "\x5c", "\x7e", "\x08"), 25, HX_HCSTRING("Main", "\x59", "\x64", "\x2f", "\x33"), HX_HCSTRING("main", "\x39", "\x38", "\x56", "\x48"));
		::haxe::Log_obj::trace(tmp7, tmp8);
			}
		}

tmp6 = (Float(::Math_obj::round(((::__time_stamp() - tmp) * ((Float)1000000.0)))) / Float(((Float)1000.0)));
tmp7 = (HX_HCSTRING("\nTIMING: ", "\xba", "\x41", "\x1a", "\xe3") + tmp6);
tmp8 = hx::SourceInfo(HX_HCSTRING("Main.hx", "\x05", "\x5c", "\x7e", "\x08"), 31, HX_HCSTRING("Main", "\x59", "\x64", "\x2f", "\x33"), HX_HCSTRING("main", "\x39", "\x38", "\x56", "\x48"));
::haxe::Log_obj::trace(tmp7, tmp8);

while ((true)) {
}
#endif