# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailing_list do
    name "Publicity"
  end

  factory :small_mailing_list, :class => MailingList do
    name "Only some members"
  end

  factory :simple_dynamic_list, :class => MailingList do
    name 'Simple dynamic list'
    query {{'forename_or_email_cont' => 'ian'}}
  end

  factory :complex_dynamic_list, :class => MailingList do
    name 'Complex dynamic list'
    query {{
      'g' => {
        '0' => {
          'm' => 'or',
          'c' => {
            '1' => {
              'a' => {
                '0' => {'name' => 'membership'}
              },
              'p' => 'eq',
              'v' => {
                '0' => {'value' => 'Life Patron'}
              }
            }
          },
          'g' => {
            '2' => {
              'm' => 'and',
              'c' => {
                '3' => {
                  'a' => {
                    '0' => {'name' => 'membership'}
                  },
                  'p' => 'eq',
                  'v' => {
                    '0' => {'value' => 'Patron'}
                  }
                },
                '4' => {
                  'a' => {
                    '0' => {'name' => 'subs_paid'}
                  },
                  'p' => 'eq',
                  'v' => {
                    '0' => {'value' => 'true'}
                  }
                }
              }
            }
          }
        }
      }
    }}
  end

  factory :list_difference, class: MailingList do
    name 'Difference between lists'
    query {{
      'g' => {
        '0' => {
          'm' => 'and',
          'c' => {
            '1' => {
              'a' => {
                '0' => {'name' => 'mailing_lists_name'}
              },
              'p' => 'eq',
              'v' => {
                '0' => {'value' => 'Publicity'}
              }
            },
            '2' => {
              'a' => {
                '0' => {'name' => 'mailing_lists_name'}
              },
              'p' => 'not_eq',
              'v' => {
                '0' => {'value' => 'Only some members'}
              }
            }
          }
        }
      }
      }}
  end
end
