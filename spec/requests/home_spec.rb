require 'spec_helper.rb'

describe 'Home page' do
  describe 'GET /' do
    let(:user) { create(:user) }
    let(:language) { create(:language) }
    let(:country) { create(:country, :name => 'USA') }

    describe 'when signed in as a RCA user or a BROADCASTER' do
      before { user.add_role Role::ROLES[:rca] }

      describe 'page view' do
        subject { response }
        before { sign_in_as_a_valid_user(user) }
        # its(:status) { should eql(200) }
        it { should render_template('index') }
      end

      describe 'data ' do
        context '@stations' do
          let(:gateways) {
            Gateway.joins("
                INNER JOIN user_assignments uasg ON gateways.id = uasg.resource_id
                  AND uasg.resource_type = 'Gateway'
                LEFT JOIN entryways ON entryways.gateway_id = gateways.id")
              .where('uasg.user_id = ?', user.id)
              .select('gateways.name as name, entryways.did as did')
          }
          let(:gateways_attrs) { gateways.collect {|g| g.attributes } }
          let(:stations_attrs) { assigns(:stations).collect {|g| g.attributes } }

          before do
            3.times do |i|
              gw = create(:gateway, name: "Gateway #{i}", language: language, country: country)
              gw.entryways.build(name: "Entryway A", :did => Faker::Base.regexify(/[0-9]{7}/), :provider => Faker::Name.name)
              user.user_assignments.build(resource: gw)
              user.save!
            end
            sign_in_as_a_valid_user(user)
          end

          # its('attributes') { expect(stations_attrs).to match_array(gateways_attrs) }
        end

        context '@listener_entryways' do
          let(:gateways) {
            Gateway.joins("
                INNER JOIN user_assignments uasg ON gateways.id = uasg.resource_id
                  AND uasg.resource_type = 'Gateway'
                LEFT JOIN entryways ON entryways.gateway_id = gateways.id
                LEFT JOIN contents ON contents.gateway_id = gateways.id
                LEFT JOIN extensions ON contents.id = extensions.content_id
                INNER JOIN listener_entryways ON listener_entryways.content_id = contents.id
                INNER JOIN listeners ON listeners.id = listener_entryways.listener_id")
              .where('uasg.user_id = ?', user.id)
              .select('gateways.name as station_name,
                contents.name as channel,
                count(*) as listeners,
                extensions.name as extension')
              .group("contents.name, gateways.name, extensions.name")
              .order("contents.name")
              .limit(5)
          }
          let(:gateways_attrs) { gateways.collect {|g| g.attributes } }
          let(:listener_entryways_attrs) { assigns(:listener_entryways).collect {|g| g.attributes } }

          before do
            6.times do |i|
              gw = build_gateway_with_constrained_data("Gateway #{i}", language, country)
              user.user_assignments.build(resource: gw)
              user.save!
            end
            sign_in_as_a_valid_user(user)
          end

          # its('attributes') { expect(listener_entryways_attrs).to match_array(gateways_attrs) }
        end

        context '@listeners' do
          let(:gateways) {
            Gateway.joins("
                INNER JOIN user_assignments uasg ON gateways.id = uasg.resource_id
                  AND uasg.resource_type = 'Gateway'
                INNER JOIN listener_entryways ON listener_entryways.gateway_id = gateways.id
                INNER JOIN listeners ON listeners.id = listener_entryways.listener_id
                INNER JOIN countries ON countries.id = gateways.country_id")
              .where('uasg.user_id = ? and countries.name = ?', user.id, "USA")
              .select('distinct(listeners.area_code)')
          }
          let(:gateways_attrs) { gateways.collect {|g| g.attributes } }
          let(:listener_attrs) { assigns(:listeners).collect {|g| g.attributes } }

          before do
            6.times do |i|
              gw = build_gateway_with_constrained_data("Gateway #{i}", language, country)
              user.user_assignments.build(resource: gw)
              user.save!
            end
            sign_in_as_a_valid_user(user)
          end

          # its('attributes') { expect(listener_attrs).to match_array(gateways_attrs) }

          context 'when do not empty' do
            # its('content') { expect(listener_attrs).to_not be_empty }
            context '@width' do
              it { expect(assigns(:width).should eq('970')) }
            end
            context '@height' do
              it { expect(assigns(:height).should eq('440')) }
            end
          end
        end
      end
    end

    describe 'when signed in as a THIRD PARTY or a MARKETER' do
      before { user.add_role Role::ROLES[:marketer] }

      describe 'home page' do
        subject { response }
        before { sign_in_as_a_valid_user(user) }
        # its(:status) { should eql(200) }
        # its(:body) { expect(response).to render_template('index') }
      end

      describe 'data' do
        context '@stations' do
          let(:entryways) {
            Entryway.joins("
                INNER JOIN user_assignments uasg ON entryways.id = uasg.resource_id
                  AND uasg.resource_type = 'Entryway'
                LEFT JOIN gateways ON entryways.gateway_id = gateways.id")
              .where('uasg.user_id = ?', user.id)
              .select('gateways.name as name, entryways.did as did')
          }
          let(:entryways_attrs) { entryways.collect {|g| g.attributes } }
          let(:stations_attrs) { assigns(:stations).collect {|g| g.attributes } }

          before do
            3.times do |i|
              gw = create(:gateway, name: "Gateway #{i}", language: language, country: country)
              enw = gw.entryways.build(name: "Entryway A", :did => Faker::Base.regexify(/[0-9]{7}/), :provider => Faker::Name.name)
              enw.save!

              user.user_assignments.build(resource: enw)
              user.save!
            end
            sign_in_as_a_valid_user(user)
          end

          # its('attributes') { expect(stations_attrs).to match_array(entryways_attrs) }
        end

        context '@listener_entryways' do
          let(:entryways) {
            Entryway.joins("
                INNER JOIN user_assignments uasg ON entryways.id = uasg.resource_id
                  AND uasg.resource_type = 'Entryway'
                LEFT JOIN gateways ON entryways.gateway_id = gateways.id
                LEFT JOIN contents ON contents.gateway_id = gateways.id
                LEFT JOIN extensions ON contents.id = extensions.content_id
                INNER JOIN listener_entryways ON listener_entryways.content_id = contents.id
                INNER JOIN listeners ON listeners.id = listener_entryways.listener_id")
              .where('uasg.user_id = ?', user.id)
              .select('gateways.name as station_name,
                contents.name as channel,
                count(*) as listeners,
                extensions.name as extension,
                entryways.did as did')
              .group("contents.name, gateways.name, extensions.name, did")
              .order("contents.name")
              .limit(5)
          }
          let(:entryways_attrs) { entryways.collect {|g| g.attributes } }
          let(:listener_entryways_attrs) { assigns(:listener_entryways).collect {|g| g.attributes } }

          before do
            6.times do |i|
              gw = build_gateway_with_constrained_data("Gateway #{i}", language, country)
              gw.save!
              gw.entryways.each do |enw|
                user.user_assignments.build(resource: enw)
                user.save!
              end
            end

            sign_in_as_a_valid_user(user)
          end
          # its('attributes') { expect(listener_entryways_attrs).to match_array(entryways_attrs) }
        end

        context '@listeners' do
          let(:entryways) {
            Entryway.joins("
                INNER JOIN user_assignments uasg ON entryways.id = uasg.resource_id
                  AND uasg.resource_type = 'Entryway'
                INNER JOIN listener_entryways ON listener_entryways.entryway_id = entryways.id
                INNER JOIN listeners ON listeners.id = listener_entryways.listener_id
                INNER JOIN gateways ON listener_entryways.gateway_id = gateways.id
                INNER JOIN countries ON countries.id = gateways.country_id")
              .where('uasg.user_id = ? and countries.name = ?', user.id, "USA")
              .select('distinct(listeners.area_code)')
          }
          let(:entryways_attrs) { entryways.collect {|g| g.attributes } }
          let(:listener_attrs) { assigns(:listeners).collect {|g| g.attributes } }

          before do
            6.times do |i|
              gw = build_gateway_with_constrained_data("Gateway #{i}", language, country)
              gw.save!
              gw.entryways.each do |enw|
                user.user_assignments.build(resource: enw)
                user.save!
              end
            end

            sign_in_as_a_valid_user(user)
          end
          # its('attributes') { expect(listener_attrs).to match_array(entryways_attrs) }

          context 'when do not empty' do
            # its('content') { expect(listener_attrs).to_not be_empty }
            context '@width' do
              it { expect(assigns(:width).should eq('970')) }
            end
            context '@height' do
              it { expect(assigns(:height).should eq('440')) }
            end
          end
        end
      end

      describe 'when signed in as a MARKETER' do
        describe 'data' do
          let(:listener_entryways) {
            ListenerEntryway.joins(:gateway => :country)
              .group("gateways.country_id, countries.name")
              .select("gateways.country_id, countries.name as country_name, 'Country' as type_name")
              .order("country_name").limit(2)
          }

          before do
            3.times do |i|
              lang = create(:language, name:"Language #{i}")
              cntry = create(:country, name:"Country #{i}")
              gw = build_gateway_with_constrained_data("Gateway", lang, cntry)
              user.user_assignments.build(resource: gw)
              user.save!
            end
            sign_in_as_a_valid_user(user)
          end

          context '@countries' do
            let(:listener_entryways_attrs) { listener_entryways.collect {|g| g.attributes } }
            let(:countries_attrs) { assigns(:countries).collect {|g| g.attributes } }
            # its('attributes') { expect(countries_attrs).to match_array(listener_entryways_attrs) }
          end

          context '@country_ids' do
            let(:ids) { assigns(:countries).collect {|g| g.country_id } }
            it { expect(assigns(:country_ids)).to match_array(ids) }
          end

          context '@series' do
            let(:g_series) { [] }
            before do
              listener_entryways.each do |country|
                data_table = GoogleVisualr::DataTable.new
                # Add Column Headers
                data_table.new_column('string', 'Date' )
                data_table.new_column('number', 'Minutes')

                # Add Rows and Values
                value = ListenerEntryway.get_report_by({country_id: country.country_id, broken_down_by: :day}, 7.days.ago)
                rows = value.map {|obj_listener| [Date.parse(obj_listener.called_date).strftime("%a %d"), obj_listener.total_minute.to_i]}
                data_table.add_rows(rows)
                options = { width: 850, height: 200, title: country.country_name}
                g_series << GoogleVisualr::Interactive::LineChart.new(data_table, options)
              end
            end

            # its('in json') { expect(assigns(:series).to_json).to eql(g_series.to_json) }
          end
        end
      end
    end
  end

  describe 'PUT /track_customize' do
    let(:url) { '/track_customize' }
    let(:user) { create(:user) }
    subject { response }
    before {
      user.add_role Role::ROLES[:marketer]
      sign_in_as_a_valid_user(user)
    }

    describe 'when removing' do
      describe 'a country from report' do
        let(:country) { create(:country) }
        context 'with children' do
          before { put url, check_list:{ country_ids:["#{country.id}_true"], status:'remove' } }
          # its(:status) { should eql(200) }
        end
        context 'without children' do
          before { put url, check_list:{ country_ids:["#{country.id}_false"], status:'remove' } }
          # its(:status) { should eql(200) }
        end

      end

      describe 'a gateway from report' do
        let(:country) { create(:country) }
        let(:language) { create(:language) }
        let(:gateway) { create(:gateway, name: Faker::Lorem.word, country:country, language:language) }
        context 'with children' do
          before { put url, check_list:{ gateway_ids:["#{gateway.id}_true"], status:'remove' } }
          # its(:status) { should eql(200) }
        end
        context 'without children' do
          before { put url, check_list:{ gateway_ids:["#{gateway.id}_false"], status:'remove' } }
          # its(:status) { should eql(200) }
        end
      end

      describe 'a content from report' do
        let(:country) { create(:country) }
        let(:language) { create(:language) }
        let(:gateway) { create(:gateway, name: Faker::Lorem.word, country:country, language:language) }
        let(:content) { create(:content, name:Faker::Lorem.word, country:country, language:language, gateway:gateway) }
        before { put url, check_list:{ content_ids:[content.id], status:'remove'} }
        # its(:status) { should eql(200) }
      end
    end

    describe 'when adding' do
      describe 'a country to report' do
        let(:country) { create(:country) }
        before do
          user.aggregate_customs.build({ removable_id:country.id, removable_type:'Country' })
          user.save!
          put url, check_list: { country_ids:["#{country.id}_true"], status:'add' }
        end
        # its(:status) { should eql(200) }
      end

      describe 'a gateway to report' do
        let(:country) { create(:country) }
        let(:language) { create(:language) }
        let(:gateway) { create(:gateway, name: Faker::Lorem.word, country:country, language:language) }
        before do
          user.aggregate_customs.build({ removable_id:gateway.id, removable_type:'Gateway' })
          user.save!
          put url, check_list: { gateway_ids:["#{gateway.id}_true"], status:'add' }
        end
        # its(:status) { should eql(200) }
      end

      describe 'a content to report' do
        let(:country) { create(:country) }
        let(:language) { create(:language) }
        let(:gateway) { create(:gateway, name: Faker::Lorem.word, country:country, language:language) }
        let(:content) { create(:content, name:Faker::Lorem.word, country:country, language:language, gateway:gateway) }
        before do
          user.aggregate_customs.build({ removable_id:content.id, removable_type:'Content' })
          user.save!
          put url, check_list: { content_ids:[content.id], status:'add' }
        end
        # its(:status) { should eql(200) }
      end
    end
  end
end