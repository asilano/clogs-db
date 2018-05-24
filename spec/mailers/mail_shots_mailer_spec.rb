require "spec_helper"

describe MailShotsMailer do
  describe "mail_shot" do

    it "renders the headers" do
      mail = MailShotsMailer.mail_shot(subject: 'Test subject',
                                       to: 'to@example.org',
                                       body: 'This is my body',
                                       reply_to_addr: 'from@example.org',
                                       attaches: [])
      mail.subject.should eq('Test subject')
      mail.to.should eq(['to@example.org'])
      mail.from.should eq(['clogs@example.com'])
    end

    it "renders the body" do
      mail = MailShotsMailer.mail_shot(subject: 'Test subject',
                                       to: 'to@example.org',
                                       body: 'This is my body',
                                       reply_to_addr: 'from@example.org',
                                       attaches: [])
      mail.body.encoded.should match('This is my body')
      mail.body.encoded.should match("RMID: #{Base64.encode64('from@example.org').chomp}")
    end

    it 'handles attachments' do
      mail = MailShotsMailer.mail_shot(subject: 'Test subject',
                                       to: 'to@example.org',
                                       body: 'This is my body',
                                       reply_to_addr: 'from@example.org',
                                       attaches: [MailShot::Attachment.new('file.txt',
                                                                           'A text file',
                                                                           'text/plain'),
                                                  MailShot::Attachment.new('image.png',
                                                                           'pretend-this-is-an-image',
                                                                           'image/png')
                                                 ])
      mail.attachments.should have(2).attachments
      attachment = mail.attachments[0]
      attachment.content_type.should start_with('text/plain')
      attachment.filename.should == 'file.txt'
      attachment = mail.attachments[1]
      attachment.content_type.should start_with('image/png')
      attachment.filename.should == 'image.png'
    end
  end

end
