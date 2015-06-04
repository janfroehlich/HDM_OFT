classdef HDM_OFT_XML_Logger
    properties
        LogFileName
        
        docNode
        progressLogOut
    end
    methods
        function XL = HDM_OFT_XML_Logger(xmlFileName)
            
            XL.LogFileName=xmlFileName;

            XL.docNode = com.mathworks.xml.XMLUtils.createDocument('OFT-IDT-Creation-Params');
            rootElem = XL.docNode.getDocumentElement;
            rootElem.setAttribute('Version','1.0.0.0');
            progressLog = XL.docNode.createElement('ProgressLog');
            XL.progressLogOut = XL.docNode.createElement('Out');
            progressLog.appendChild(XL.progressLogOut);
            rootElem.appendChild(progressLog);            
                        
        end
        
        function LogUserMessage(XL,message)
            
            progressLogOutMessage = XL.docNode.createElement('Message');
            XL.progressLogOut.appendChild(progressLogOutMessage);
            progressLogOutMessageUsrMsg = XL.docNode.createElement('UserMessage');
            
            progressLogOutMessageUsrMsg.appendChild(XL.docNode.createTextNode(message));
            
            progressLogOutMessage.appendChild(progressLogOutMessageUsrMsg);
            progressLogOutMessageLvl = XL.docNode.createElement('Level');
            progressLogOutMessageLvl.appendChild(XL.docNode.createTextNode('User'));
            progressLogOutMessage.appendChild(progressLogOutMessageLvl);
            progressLogOutMessageDate = XL.docNode.createElement('Date');
            progressLogOutMessageDate.appendChild(XL.docNode.createTextNode(datestr(now,'yyyy mm dd HH.MM.SS AM')));
            progressLogOutMessage.appendChild(progressLogOutMessageDate);

            xmlwrite(XL.LogFileName,XL.docNode);

        end
    end
end