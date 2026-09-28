/* Synthetic minimal documents in the observed schema. NOT an actual T21 scan. */
#ifndef DIZZASS_HWSCAN_FIXTURE_H
#define DIZZASS_HWSCAN_FIXTURE_H
static const char fixture_fw_json[]="{\"platform\":\"aml\"}";
static const char fixture_model_json[]=
"{\"model\":\"synthetic-bm1368\",\"algorithm\":\"sha256d\",\"num_boards\":3,\"bypass_mode\":false,"
"\"board\":{\"num_chips\":108},\"chip\":{\"model\":\"BM1368\",\"uart_speed\":115200,\"ver_roll_mask\":0,\"ticket_mask\":255}}";
static const char fixture_hw_json[]=
"{\"status\":\"ok\",\"model\":\"synthetic-detection\",\"boards\":["
"{\"id\":2,\"model\":\"synthetic-board\",\"status\":\"ok\"},"
"{\"id\":0,\"model\":\"synthetic-board\",\"status\":\"disconnected\"}]}";
#endif
